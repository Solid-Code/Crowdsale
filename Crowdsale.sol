pragma solidity ^0.4.18;

library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) <= a);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) >= a);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c == 0 || (c = a * b) / b == a));
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a / b;
    }
}

interface Token {
    function mintTokens(address _recipient, uint _value);
    function balanceOf(address _holder) returns(uint256 tokens);
    function totalSupply() returns(uint256 totalSupply);
    function crowdsaleSucceeded();
}

contract Crowdsale {
    using SafeMath for uint256;
    
    Token public tokenContract;
    
    address public beneficiaryAddress;
    uint256 public minimumContribution;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public startTime;
    uint256 public endTime;
    int8 public heldPercent;
    uint256 public baseTokensPerEth;
    uint256[] public bonusPercents;
    uint256[] public bonusHours;
    uint256 public fundsRaised;
    mapping (address => uint256) public contributionBy;
    
    event ContributionReceived(address contributer, uint256 amount, uint256 totalContributions,uint totalAmountRaised, uint256 tokensMinted, bool softCapMet);
    event FinalalizeCrowdsale(uint256 contributionsRecieved, address beneficiaryAddress, uint256 totalTokensAssigned, uint256 foundersTokens);
    event PaidRefund(address recipient, uint256 amount);

    function Crowdsale(
        address _beneficiaryAddress,
        int8 _heldPercent,
        uint256 _minimumContributionInFinney,
        uint256 _softCapInEther,
        uint256 _hardCapInTokens,
        uint256 _baseTokensPerEth,
        uint256 _startTimeInHoursFromNow,
        uint256 _saleLengthinHours,
        uint256[] _bonusPercents,
        uint256[] _bonusTimes,
        address _tokenContractAddress ) {
        beneficiaryAddress = _beneficiaryAddress;
        heldPercent = _heldPercent;
        minimumContribution = _minimumContributionInFinney.mul(1 finney);
        softCap = _softCapInEther.mul(1 ether);
        hardCap = _hardCapInTokens.mul(1e18);
        baseTokensPerEth = _baseTokensPerEth;
        startTime = now.add(_startTimeInHoursFromNow.mul(1 hours));
        endTime = startTime.add(_saleLengthinHours.mul(1 hours));
        bonusPercents = _bonusPercents;
        bonusHours = _bonusTimes;
        tokenContract = Token(_tokenContractAddress);
    }

    function () public payable {
        require(crowdsaleStarted());
        require(!crowdsaleOver());
        require(msg.value >= minimumContribution);
        contributionBy[msg.sender] = contributionBy[msg.sender].add(msg.value);
        fundsRaised = fundsRaised.add(msg.value);
        uint256 tokensMinted = msg.value.mul(tokensPerEth());
        if(tokenContract.totalSupply().add(tokensMinted) > hardCap) {
                uint256 partialTokensMinted = tokensMinted.sub(tokenContract.totalSupply().add(tokensMinted).sub(hardCap));
                uint256 refund = partialTokensMinted.div(tokensMinted).mul(msg.value);
                tokensMinted = partialTokensMinted;
                msg.sender.transfer(refund);
        }
        tokenContract.mintTokens(msg.sender, tokensMinted);
        ContributionReceived(msg.sender, msg.value, contributionBy[msg.sender],fundsRaised, tokensMinted, softCapExceeded());
    }

    function softCapExceeded() internal view returns(bool) {return (fundsRaised >= softCap);}
    function hardCapMet() internal view returns(bool) {return (fundsRaised >= hardCap);}
    function crowdsaleStarted() internal view returns(bool) {return(now >= startTime);}
    function crowdsaleOver() internal view returns(bool) {return (hardCapMet() || now >= endTime);}
    function crowdsaleFailed() internal view returns(bool) {return(!softCapExceeded() && now >= endTime);}
    

    /*Provide:
        bonusHours {24,24,24,24}
        bonusPercents {30,20,10,0}
    */
    function tokensPerEth() view public returns(uint256 _tokensPerEth) {
        uint256 timeSinceStart = now.min(startTime);
        uint256 totalBonusTime = 0;
        for(uint16 i = 0; totalBonusTime >= timeSinceStart; i++){
            totalBonusTime += bonusHours[i].mul(1 hours);
        }
        _tokensPerEth = baseTokensPerEth.add(baseTokensPerEth.mul(bonusPercents[i]));
    }
    
    function withdrawRefund() public {
        require(crowdsaleFailed());
        uint256 amount = contributionBy[msg.sender];
        require(contributionBy[msg.sender] > 0);
        contributionBy[msg.sender] = 0;
        require(amount > 0);
        msg.sender.transfer(amount);
        PaidRefund(msg.sender,amount);
    }
    
    function finalizeCrowdsale() public {
        require(softCapExceeded());
        require(crowdsaleOver());
        require(this.balance > 0); 
        uint256 totalTokensMinted = tokenContract.totalSupply();
        tokenContract.crowdsaleSucceeded();
        beneficiaryAddress.transfer(this.balance);
        uint256 foundersTokens = uint256((-1 * heldPercent * int256(totalTokensMinted)) / (heldPercent - 100));
        tokenContract.mintTokens(beneficiaryAddress, foundersTokens);
        totalTokensMinted = tokenContract.totalSupply();
        FinalalizeCrowdsale(fundsRaised, beneficiaryAddress, totalTokensMinted, foundersTokens);
    }
}




