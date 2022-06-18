pragma solidity ^0.4.24;

//import "./IERC20.sol";
import "./ERC20Detailed.sol";
import "./SafeMath.sol";
import "./Roster.sol";


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
  contract ERC20 is ERC20Detailed {
    using SafeMath for uint256;
    using Roster for Roster.roster;

    event  SetWhite(address,uint8);
    event  RemoveWhite(address,uint8);

    event  SetAllotAddress(address,uint8);

    event OwnershipTransferred(address, address);
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    address _owner;
   
    //Release of the pool
    address public addressRelease;
    
    address public addressFixed;
    //LP Pool
    address public addressLp;
    //white list (from)
    Roster.roster public whiteListFrom;
      //white list (to)
    Roster.roster public whiteListTo;

    uint constant digit = 1E18;
    constructor (string name, string symbol, uint256 total ) public ERC20Detailed(name, symbol,18)  {
        _owner = msg.sender;
        _totalSupply =total.mul(digit);
        _balances[msg.sender] = _totalSupply;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

    function setReleaseAddress(address _address) external onlyOwner{
        require(_address != address(0),"The address is empty");
        addressRelease = _address;
        emit SetAllotAddress(_address,1);
    }

    function setLpAddress(address _address) external onlyOwner{
        require(_address != address(0),"The address is empty");
        addressLp = _address;
        emit SetAllotAddress(_address,2);
    }
    
    function setFixedAddress(address _address) external onlyOwner{
        require(_address != address(0),"The address is empty");
        addressFixed = _address;
        emit SetAllotAddress(_address,3);
    }

    function WhiteFromList() external view returns(address[] memory){
      return(whiteListFrom.details());
    }
    function WhiteToList() external view returns(address[] memory){
      return(whiteListTo.details());
    }
    function WhiteFrom(address _address) external view returns(bool){
      return(whiteListFrom.isexists(_address));
    }
    function WhiteTo(address _address) external view returns(bool){
      return(whiteListTo.isexists(_address));
    }
  
    function SetWhiteFrom(address _address) external onlyOwner{
        whiteListFrom.set(_address,1);
    }

    function RemoveWhiteFrom(address _address) external onlyOwner{ 
      whiteListFrom.remove(_address,1);
    }

    function SetWhiteTo(address _address) external onlyOwner{
      whiteListTo.set(_address,2);
    }

    function RemoveWhiteTo(address _address) external onlyOwner{ 
      whiteListTo.remove(_address,2);
    }
  
    function transferOwnership(address _newOwner) external   onlyOwner {
        require(_newOwner != address(0), "  new owner is the zero address");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
  

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) external view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    external
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) external returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) external returns (bool) {
    require(spender != address(0),"the address is empty");

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender],"Transfer amount greater than current balance");

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    external
    returns (bool)
  {
    require(spender != address(0),"the address is empty");

    _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    external
    returns (bool)
  {
    require(spender != address(0),"the address is empty");

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from],"Transfer amount greater than current balance");
    require(to != address(0),"to address is empty");

    uint valueM = value;
      if ((!whiteListFrom.isexists(from) ) && (!whiteListTo.isexists(to))){
          require(addressRelease != address(0),"Release address is empty");
          require(addressLp != address(0),"Lp address is empty");
          require(addressFixed != address(0),"Fixed address is empty");
         
          uint valueRelease = value.mul(2).div(100);
          uint valueFixed = value.mul(2).div(100);
          uint valueLp = value.mul(6).div(100);
          //to address Value
          valueM = value.sub(valueRelease).sub(valueFixed).sub(valueLp);
          //Release pool Buckle point
          _balances[from] = _balances[from].sub(valueRelease);
          _balances[addressRelease] = _balances[addressRelease].add(valueRelease);
          emit Transfer(from, addressRelease, valueRelease);
          //Fixed address Buckle point
           _balances[from] = _balances[from].sub(valueFixed);
          _balances[addressFixed] = _balances[addressFixed].add(valueFixed);
          emit Transfer(from, addressFixed, valueFixed);
           //Lp pool Buckle point
          _balances[from] = _balances[from].sub(valueLp);
          _balances[addressLp] = _balances[addressLp].add(valueLp);
           emit Transfer(from, addressLp, valueLp);
      }
      _balances[from] = _balances[from].sub(valueM);
      _balances[to] = _balances[to].add(valueM);
      emit Transfer(from, to, valueM);
  }
}
