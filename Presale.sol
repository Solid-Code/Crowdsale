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
    function mintTokens(address _recipient, uint _value) public;
    function balanceOf(address _holder) public returns(uint256 tokens);
    function totalSupply() public returns(uint256 _totalSupply);
}

contract Presale {
    using SafeMath for uint256;
    
    Token public tokenContract;

    address public beneficiaryAddress;
    uint256 public minimumContribution;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public tokensPerEther;

    mapping (address => uint256) public contributionBy;
    
    event ContributionReceived(address contributer, uint256 amount, uint256 totalContributions,uint totalAmountRaised);
    event FundsWithdrawn(uint256 funds, address beneficiaryAddress);

    function Presale(
        address _beneficiaryAddress,
        uint256 _tokensPerEther,
        uint256 _minimumContributionInFinney,
        uint256 _startTimeInHoursFromNow,
        uint256 _saleLengthinHours,
        address _tokenContractAddress) {
        startTime = now + (_startTimeInHoursFromNow * 1 hours);
        endTime = startTime + (_saleLengthinHours * 1 hours);
        beneficiaryAddress = _beneficiaryAddress;
        tokensPerEther = _tokensPerEther;
        minimumContribution = _minimumContributionInFinney * 1 finney;
        tokenContract = Token(_tokenContractAddress);
    }

    function () public payable {
        require(presaleOpen());
        require(msg.value >= minimumContribution);
        contributionBy[msg.sender] = contributionBy[msg.sender].add(msg.value);
        tokenContract.mintTokens(msg.sender, msg.value.mul(tokensPerEther));
        ContributionReceived(msg.sender, msg.value, contributionBy[msg.sender], this.balance);
    }


    function presaleOpen() internal view returns(bool) {return(now >= startTime && now <= endTime);} 

    function withdrawFunds() public {
        require(this.balance > 0);
        beneficiaryAddress.transfer(this.balance);
        FundsWithdrawn(this.balance, beneficiaryAddress);
    }
}
