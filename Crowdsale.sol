pragma solidity ^0.4.16;

library SafeMath {// Partial SafeMath Library

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) <= a);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) >= a);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a * b) >= a);
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
    uint256 public hardCap;
    uint256 public softCap;
    uint256 public startTime;
    uint256 public endTime;
    int8 public heldPercent;
    uint256 public baseTokensPerEth;
    uint256[] public bonusPercents;
    uint256[] public bonusHours;
    uint256 public fundsRaised;
    bool public softCapMet;
    bool public hardCapMet;
    mapping (address => uint256) public contributionBy;
    
    event ContributionReceived(address contributer, uint256 amount, uint256 totalContributions,uint totalAmountRaised, uint256 tokensMinted, bool softCapMet);
    event FinalalizeCrowdsale(uint256 contributionsRecieved, address beneficiaryAddress, uint256 totalTokensAssigned, uint256 foundersTokens);
    event PaidRefund(address recipient, uint256 amount);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    function Crowdsale(
        address _beneficiaryAddress,
        int8 _heldPercent,
        uint256 _softCapInEther,
        uint256 _hardCapInEther,
        uint256 _baseTokensPerEth,
        uint256 _startTimeInHoursFromNow,
        uint256 _saleLengthinHours,
        uint256[] _bonusPercents,
        uint256[] _bonusTimes,
        address _tokenContractAddress ) {
        beneficiaryAddress = _beneficiaryAddress;
        heldPercent = _heldPercent;
        softCap = _softCapInEther * 1 ether;
        hardCap = _hardCapInEther * 1 ether;
        baseTokensPerEth = _baseTokensPerEth;
        startTime = now + _startTimeInHoursFromNow * 1 hours;
        endTime = startTime + _saleLengthinHours * 1 hours;
        bonusPercents = _bonusPercents;
        bonusHours = _bonusTimes;
        tokenContract = Token(_tokenContractAddress);
    }

    function () public payable {
        require(crowdsaleStarted());
        require(!crowdsaleOver());
        contributionBy[msg.sender] += msg.value;
        fundsRaised += msg.value;
        uint256 tokensMinted = msg.value.mul(tokensPerEth());
        tokenContract.mintTokens(msg.sender, tokensMinted);
        ContributionReceived(msg.sender, msg.value, contributionBy[msg.sender],fundsRaised, tokensMinted,softCapReached());
    }


    function softCapReached() internal view returns(bool) {return (fundsRaised >= softCap);}
    function hardCapExceeded() internal view returns(bool) {return (fundsRaised >= hardCap);}
    function crowdsaleStarted() internal view returns(bool) {return(now >= startTime);}
    function crowdsaleOver() internal view returns(bool) {return (hardCapExceeded() || now >= endTime);}
    function crowdsaleFailed() internal view returns(bool) {return(!softCapReached() && now >= endTime);}
    
    
    
    /*Provide:
        bonusHours {24,24,24,24,24*7
    
    and bonusPercents arrays */
    function tokensPerEth() view public returns(uint256 _tokensPerEth) {
        uint256 timeSinceStart = now - startTime;
        uint256 totalBonusTime = 0;
        for(uint16 i = 0; totalBonusTime >= timeSinceStart; i++){
            totalBonusTime += bonusHours[i] * 1 hours;
        }
        _tokensPerEth = baseTokensPerEth + baseTokensPerEth * bonusPercents[i];
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
        require(softCapReached());
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




