pragma solidity ^0.4.17;

library SafeMathMod {// Partial SafeMath Library

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) < a);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) > a);
    }
}

contract Token {//is inherently ERC20
    using SafeMathMod for uint256;

    /**
    * @constant name The name of the token
    * @constant symbol  The symbol used to display the currency
    * @constant decimals  The number of decimals used to dispay a balance
    * @constant totalSupply The total number of tokens times 10^ of the number of decimals
    * @constant MAX_UINT256 Magic number for unlimited allowance
    * @storage balanceOf Holds the balances of all token holders
    * @storage allowance Holds the allowable balance to be transferable by another address.
    */

    string constant public name = "Token";

    string constant public symbol = "TKN";

    uint8 constant public decimals = 18;

    uint256 public totalSupply;

    uint256 constant private MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event TransferFrom(address indexed _spender, address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    event Mint(address indexed _to, uint256 _value, uint256 _totalSupply);

    event Burn(address indexed _from, uint256 _value, uint256 _totalSupply);

    address public presaleAddress;
    
    address public crowdsaleAddress;
    
    bool public crowdsaleSuccessful;

    function Token(address _presaleAddress, address _crowdsaleAddress) public {
        totalSupply = 0;
        presaleAddress = _presaleAddress;
        crowdsaleAddress = _crowdsaleAddress;
    }

    /**
    * @notice send `_value` token to `_to` from `msg.sender`
    *
    * @param _to The address of the recipient
    * @param _value The amount of token to be transferred
    * @return Whether the transfer was successful or not
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(crowdsaleSuccessful);
        /* Ensures that tokens are not sent to address "0x0" */
        require(_to != address(0));
        /* SafeMathMOd.sub will throw if there is not enough balance and if the transfer value is 0. */
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        success = true;
    }

    /**
    * @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    *
    * @param _from The address of the sender
    * @param _to The address of the recipient
    * @param _value The amount of token to be transferred
    * @return Whether the transfer was successful or not
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(crowdsaleSuccessful);
        /* Ensures that tokens are not sent to address "0x0" */
        require(_to != address(0));
        /* Ensures tokens are not sent to this contract */
        require(_to != address(this));
        
        uint256 allowed = allowance[_from][msg.sender];
        /* Ensures sender has enough available allowance OR sender is balance holder allowing single transsaction send to contracts*/
        require(_value <= allowed || _from == msg.sender);

        /* Use SafeMathMod to add and subtract from the _to and _from addresses respectively. Prevents under/overflow and 0 transfers */
        balanceOf[_to] = balanceOf[_to].add(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);

        /* Only reduce allowance if not MAX_UINT256 in order to save gas on unlimited allowance */
        /* Balance holder does not need allowance to send from self. */
        if (allowed != MAX_UINT256 && _from != msg.sender) {
            allowance[_from][msg.sender] = allowed.sub(_value);
        }
        Transfer(_from, _to, _value);
        success = true;
    }

    /**
    * @notice `msg.sender` approves `_spender` to spend `_value` tokens
    *
    * @param _spender The address of the account able to transfer the tokens
    * @param _value The amount of tokens to be approved for transfer
    * @return Whether the approval was successful or not
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        /* Ensures address "0x0" is not assigned allowance. */
        require(_spender != address(0));

        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }
    
    function mintTokens(address _to, uint256 _value) public returns(bool success) {
        require(msg.sender == presaleAddress || msg.sender == crowdsaleAddress);
        balanceOf[_to] = balanceOf[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        Mint(_to,  _value, totalSupply);
        success = true;
    }
    
    function burnAllTokens(address _from) public returns(bool success) {
        require(msg.sender == presaleAddress || msg.sender == crowdsaleAddress);
        uint256 amount = balanceOf[_from];
        balanceOf[_from] = 0;
        totalSupply = totalSupply.sub(amount);
        Burn(_from,  amount, totalSupply);
        success = true;
    }

    function crowdsaleSucceeded() public {
        require(msg.sender == crowdsaleAddress);
        crowdsaleSuccessful = true;
    }
    
    // revert on eth transfers to this contract
    function() public payable {revert();}
}
