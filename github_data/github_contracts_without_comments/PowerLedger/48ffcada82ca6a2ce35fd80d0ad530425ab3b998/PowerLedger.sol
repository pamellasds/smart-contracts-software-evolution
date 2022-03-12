pragma solidity 0.4.24;

import ;

contract powerledger is erc20tokeninterface {

  
  string public constant name = ;
  uint256 public constant decimals = 6;
  string public constant symbol = ;
  string public constant version = ;
  string public constant note = ;

  
  uint256 private constant totaltokens = 1000000000 * (10 ** decimals);

  mapping (address => uint256) public balances; 
  
  
  mapping (address => mapping (address => uint256)) public allowed; 

  
  event migrationinfoset(string newmigrationinfo);

  
  
  
  string public migrationinfo = ;

  
  address public migrationinfosetter;

  
  modifier onlyfrommigrationinfosetter {
    require (msg.sender == migrationinfosetter);
    _;
  }

  
  constructor() public {
    
    balances[msg.sender] = totaltokens;
  }

  
  function totalsupply() constant public returns (uint256) {
    return totaltokens;
  }

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    if (balances[msg.sender] >= _value) {
      balances[msg.sender] = _value;
      balances[_to] += _value;
      emit transfer(msg.sender, _to, _value);
      return true;
    }
    return false;
  }

  
  function transferfrom(address _from, address _to, uint256 _value) public returns (bool) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
      balances[_from] = _value;
      allowed[_from][msg.sender] = _value;
      balances[_to] += _value;
      emit transfer(_from, _to, _value);
      return true;
    }
    return false;
  }

  
  function balanceof(address _owner) constant public returns (uint256) {
    return balances[_owner];
  }

  
  
  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit approval(msg.sender, _spender, _value);
    return true;
  }

  
  function compareandapprove(address _spender, uint256 _currentvalue, uint256 _newvalue) public returns(bool) {
    if (allowed[msg.sender][_spender] != _currentvalue) {
      return false;
    }
    return approve(_spender, _newvalue);
  }

  
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  
  
  
  
  function setmigrationinfo(string _migrationinfo) onlyfrommigrationinfosetter public {
    migrationinfo = _migrationinfo;
    emit migrationinfoset(_migrationinfo);
  }

  
  
  
  
  function changemigrationinfosetter(address _newmigrationinfosetter) onlyfrommigrationinfosetter public {
    migrationinfosetter = _newmigrationinfosetter;
  }
}