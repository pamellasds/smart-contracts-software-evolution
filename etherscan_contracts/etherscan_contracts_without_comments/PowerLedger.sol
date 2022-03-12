

pragma solidity 0.4.11;

contract erc20tokeninterface {

    
    function totalsupply() constant returns (uint256 supply);

    
    
    function balanceof(address _owner) constant public returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event transfer(address indexed from, address indexed to, uint256 value);
    event approval(address indexed owner, address indexed spender, uint256 value);
}

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
    if (msg.sender != migrationinfosetter) {
      throw;
    }
    _;
  }

  
  function powerledger(address _migrationinfosetter) {
    if (_migrationinfosetter == 0) throw;
    migrationinfosetter = _migrationinfosetter;
    
    balances[msg.sender] = totaltokens;
  }

  
  function totalsupply() constant returns (uint256) {
    return totaltokens;
  }

  
  
  
  
  
  
  function transfer(address _to, uint256 _value) public returns (bool) {
    if (balances[msg.sender] >= _value) {
      balances[msg.sender] = _value;
      balances[_to] += _value;
      transfer(msg.sender, _to, _value);
      return true;
    }
    return false;
  }

  
  function transferfrom(address _from, address _to, uint256 _value) public returns (bool) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
      balances[_from] = _value;
      allowed[_from][msg.sender] = _value;
      balances[_to] += _value;
      transfer(_from, _to, _value);
      return true;
    }
    return false;
  }

  
  function balanceof(address _owner) constant public returns (uint256) {
    return balances[_owner];
  }

  
  
  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
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
    migrationinfoset(_migrationinfo);
  }

  
  
  
  
  function changemigrationinfosetter(address _newmigrationinfosetter) onlyfrommigrationinfosetter public {
    migrationinfosetter = _newmigrationinfosetter;
  }
}