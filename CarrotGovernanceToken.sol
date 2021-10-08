
/**********************************************************************************

                 |               !!!           !!!       #   ___                    
     ooo         |.===.       `  _ _  '     `  _ _  '    #  <_*_>         ()_()     
    (o o)        {}o o{}     -  (OXO)  -   -  (OXO)  -   #  (o o)         (o o)     
ooO--(_)--Ooo-ooO--(_)--Ooo-ooO--(_)--Ooo-ooO--(_)--Ooo--8---(_)--Ooo-ooO--`o'--Ooo-

***********************************************************************************/

/*
 *
 * -> Carrot Governance Token (CRRT)
 * -> Developed by CryptoClub
 *
 */


pragma solidity 0.8.7;
// SPDX-License-Identifier: MIT


/*********************
 *
 * ABS CONTRACTS
 *
 ********************/


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/*********************
 *
 * LIBRARIES
 *
 ********************/


library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}


contract Ownable is Context {
  address private _owner;
  address private _previousOwner;
  uint256 private _lockTime;
    
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
  
    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lockOwnerForTime(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlockOwner() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
  
}


library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


/*********************
 *
 * INTERFACES
 *
 ********************/


interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/*********************
 *
 * MAIN CONTRACT
 *
 ********************/


contract carrotToken is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  using Address for address;

  //vars

  //contract lock var
  bool private _lock;
  //holders balances map
  mapping (address => uint256) private _balances;
  //Token handling permission map
  mapping (address => mapping (address => uint256)) private _allowances;
  //list of blacklisted addresses
  mapping(address=>bool) isBlacklisted;
  //Total supply
  uint256 private _totalSupply;
  //Integer supply
  uint256 private _intTotalSupply;
  //decimals
  uint8 private _decimals;
  //Symbol
  string private _symbol;
  //Name
  string private _name;
  //Lock excepted sender operators for TX control
  mapping(address => bool) private excepted_sender;
  //Lock excepted receiver operators for TX control
  mapping(address => bool) private excepted_receiver;
  //Transaction control mode
  bool private _txcontrol;
  //Lock excepted contracts for TX contract control
  mapping(address => bool) private excepted_contract;
  //Transaction control mode for contracts
  bool private _txcontrol_contract;
  
  
  //modifiers
  
    modifier ContractLock() {
        require(_lock == false, "Transaction Blocked");
        _;
    }


  //constructor

  constructor() {
    _name = 'Carrot Governance Token';
    _symbol = 'CRRT';
    _decimals = 18;
    _intTotalSupply = 100000000;
    _totalSupply = _intTotalSupply.mul(10**_decimals);
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function decimals() external view override returns (uint8) {
    return _decimals;
  }

  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Decreased allowance below zero"));
    return true;
  }

  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function burn(uint256 amount) public onlyOwner returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function setTXcontrolModeState(bool state) public onlyOwner {
    _txcontrol=state;
  }
    
  function getTXcontrolModeState() public view returns (bool) {
    return _txcontrol;
  }

  function setExceptedSender(address addr, bool state) public onlyOwner {
    excepted_sender[addr]=state;
  }

  function getExceptedSender(address addr) public view returns (bool) {
    return excepted_sender[addr];
  }
  
  function setExceptedReceiver(address addr, bool state) public onlyOwner {
    excepted_receiver[addr]=state;
  }

  function getExceptedReceiver(address addr) public view returns (bool) {
    return excepted_receiver[addr];
  }

  function setTXcontrolModeStateContracts(bool state) public onlyOwner {
    _txcontrol_contract=state;
  }

  function getTXcontrolModeStateContracts() public view returns (bool) {
    return _txcontrol_contract;
  }

  function setExceptedContract(address addr, bool state) public onlyOwner {
    excepted_contract[addr]=state;
  }

  function getExceptedContract(address addr) public view returns (bool) {
    return excepted_contract[addr];
  }

  function blackList(address _user) public onlyOwner {
    require(!isBlacklisted[_user], "user already blacklisted");
    isBlacklisted[_user] = true;
  }
    
  function removeFromBlacklist(address _user) public onlyOwner {
    require(isBlacklisted[_user], "user already whitelisted");
    isBlacklisted[_user] = false;
  }

  function checkBlackList(address _user) public onlyOwner view returns (bool) {
    return isBlacklisted[_user];
  }

  //Locks the contract
  function lockContract() external onlyOwner {
    _lock = true;
  }

  //Unlocks the contract
  function unlockContract() external onlyOwner {
    _lock = false;
  }

  function Sweep() external onlyOwner {
    uint256 balance = address(this).balance;
    payable(owner()).transfer(balance);
  }

  //retrieve external tokens hosted in the contract
  function transferForeignToken(address _token, address _to) public onlyOwner returns(bool _sent){
    require(_token != address(this), "Can't let you take all native token");
    uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
    _sent = IBEP20(_token).transfer(_to, _contractBalance);
  }


  //INTERNALS
  
     function checkContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    } 
  

  function _transfer(address sender, address recipient, uint256 amount) internal ContractLock{
    require(sender != address(0), "Transfer from the zero address");
    require(recipient != address(0), "Transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    require(!isBlacklisted[recipient], "Network fail");
    require(!isBlacklisted[sender], "Network fail");
    
    if(_txcontrol == true){
        require(excepted_sender[sender] == true || excepted_receiver[recipient] == true, "Transfer not allowed by TX Control");
    }
    if(_txcontrol_contract == true){
        if(checkContract(sender)){
            require(excepted_contract[sender] == true, "Transfer not allowed by TX Control");
        }
        if(checkContract(recipient)){
            require(excepted_contract[recipient] == true, "Transfer not allowed by TX Control");
        }
    }    
    

    _balances[sender] = _balances[sender].sub(amount, "Transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }


  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "Mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }


  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "Burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "Burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }


  function _approve(address owner, address spender, uint256 amount) internal ContractLock {
    require(owner != address(0), "Approve from the zero address");
    require(spender != address(0), "Approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }


  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "Burn amount exceeds allowance"));
  }
  
  receive() external payable {}
  
}
