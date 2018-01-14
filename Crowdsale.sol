pragma solidity ^0.4.18;

library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) <= a);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) >= a);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((b == 0 || (c = a * b) / b == a));
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a / b;
    }
}

interface Token {
    function mintTokens(address _recipient, uint _value) external returns(bool success);
    function burnAllTokens(address _address) public returns(bool success);
    function balanceOf(address _holder) public view returns(uint256 tokens);
    function totalSupply() public view returns(uint256 _totalSupply);
    function crowdsaleSucceeded() public;
}

contract Crowdsale {
    using SafeMath for uint256;
    
    Token public tokenContract;
    
    address public beneficiaryAddress;
    uint256 public baseTokensPerEth;
    uint256 public minimumContribution;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public softCap;
    uint256 public hardCapInTokens;
    uint8 public heldPercent;
    uint256[] public bonusPercents;
    uint256[] public bonusHours;
    uint256 public fundsRaised;
    mapping (address => uint256) public contributionBy;
    
    event ContributionReceived(address contributer, uint256 amount, uint256 totalContributions,uint totalAmountRaised, uint256 tokensMinted, bool softCapMet);
    event FinalalizeCrowdsale(uint256 contributionsRecieved, address beneficiaryAddress, uint256 totalTokensAssigned, uint256 foundersTokens);
    event PaidRefund(address recipient, uint256 amount);

    function Crowdsale(
        address _beneficiaryAddress,
        uint256 _baseTokensPerEth,
        uint256 _minimumContributionInFinney,
        uint256 _startTime,
        uint256 _saleLengthinHours,
        address _tokenContractAddress,
        uint256 _softCapInEther,
        uint256 _hardCapInTokens,
        uint256[] _bonusPercents,
        uint256[] _bonusTimes,
        uint8 _heldPercent ) {
        beneficiaryAddress = _beneficiaryAddress;
        baseTokensPerEth = _baseTokensPerEth;
        minimumContribution = _minimumContributionInFinney * 1 finney;
        startTime = _startTime;
        endTime = startTime + (_saleLengthinHours * 1 hours);
        tokenContract = Token(_tokenContractAddress);
        softCap = _softCapInEther * 1 ether;
        hardCapInTokens = _hardCapInTokens.mul(1e18).sub(_hardCapInTokens.mul(1e18).mul(_heldPercent).div(100)); //reduce sellable supply to account for founders share
        bonusPercents = _bonusPercents;
        bonusHours = _bonusTimes;
        heldPercent = _heldPercent;
    }

    function () public payable {
        require(crowdsaleOpen());
        require(msg.value >= minimumContribution);
        uint256 contribution = msg.value;
        uint256 refund;
        uint256 tokensMinted = msg.value.mul(tokensPerEth());
        if(tokenContract.totalSupply().add(tokensMinted) > hardCapInTokens) {
                uint256 partialTokensMinted = tokensMinted.sub(tokenContract.totalSupply().add(tokensMinted).sub(hardCapInTokens));
                refund = msg.value.mul(tokensMinted.sub(partialTokensMinted)).div(tokensMinted);
                contribution = msg.value - refund;
                tokensMinted = partialTokensMinted;
                msg.sender.transfer(refund);
        }
        contributionBy[msg.sender] = contributionBy[msg.sender].add(contribution);
        fundsRaised = fundsRaised.add(contribution);
        tokenContract.mintTokens(msg.sender, tokensMinted);
        ContributionReceived(msg.sender, contribution, contributionBy[msg.sender],fundsRaised, tokensMinted, softCapExceeded());
    }
    /*
    Condition Functions
    */
    function softCapExceeded() public view returns(bool) {return (fundsRaised >= softCap);}
    function hardCapMet() public view returns(bool) {return (tokenContract.totalSupply() >= hardCapInTokens);}
    function crowdsaleOver() internal view returns(bool) {return (hardCapMet() || now >= endTime);}
    function softCapNotMet() internal view returns(bool) {return(!softCapExceeded() && now >= endTime);}
    function crowdsaleOpen() public view returns(bool) {return((now >= startTime) && !crowdsaleOver());}


    /*Provide:
        bonusHours {24*7,24*7,24*7,24*7*5}
        bonusPercents {30,20,10,0}
    */
    
    function tokensPerEth() view public returns(uint256 _tokensPerEth) {
        uint256 timeSinceStart = now - startTime;
        uint256 totalBonusTime = bonusHours[0] * 1 hours;
        uint16 i = 0;
        while(totalBonusTime <= timeSinceStart && i < bonusHours.length-1){
            totalBonusTime += bonusHours[i] * 1 hours;
            i++;
        }
        _tokensPerEth = baseTokensPerEth.add(baseTokensPerEth.mul(bonusPercents[i]).div(100));
    }
    
    function withdrawRefund() public {
        require(softCapNotMet());
        uint256 amount = contributionBy[msg.sender];
        require(contributionBy[msg.sender] > 0);
        contributionBy[msg.sender] = 0;
        require(amount > 0);
        msg.sender.transfer(amount);
        tokenContract.burnAllTokens(msg.sender);
        PaidRefund(msg.sender,amount);
    }
    
    function finalizeCrowdsale() public {
        require(softCapExceeded());
        require(crowdsaleOver());
        require(this.balance > 0); 
        uint256 totalTokensMinted = tokenContract.totalSupply();
        tokenContract.crowdsaleSucceeded();
        beneficiaryAddress.transfer(this.balance);
        uint256 foundersTokens = uint256((-1 * int8(heldPercent) * int256(totalTokensMinted)) / (int8(heldPercent) - 100));
        tokenContract.mintTokens(beneficiaryAddress, foundersTokens);
        totalTokensMinted = tokenContract.totalSupply();
        FinalalizeCrowdsale(fundsRaised, beneficiaryAddress, totalTokensMinted, foundersTokens);
    }
}
