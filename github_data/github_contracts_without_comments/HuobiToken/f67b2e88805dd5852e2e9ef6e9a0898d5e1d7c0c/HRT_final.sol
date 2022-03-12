pragma solidity ^0.4.16;
 
 
contract ownable {
    
  address public owner;
  uint public start;
 
  
  function ownable() {
    owner = msg.sender;
  }
 
  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }
  
  modifier tokenison() {
    if (msg.sender != owner){
    require(now > start);
    _;}
    _;
  }
 
  
  function transferownership(address newowner) onlyowner {
    require(newowner != address(0));      
    owner = newowner;
  }
  
  function starttoken(uint startdate) onlyowner {
      start = startdate;
  }
 
}
 

contract erc20basic is ownable {
  uint256 public totalsupply;
  function balanceof(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}
 

contract erc20 is erc20basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferfrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event approval(address indexed owner, address indexed spender, uint256 value);
}
 

library safemath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a  b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}
 

contract basictoken is erc20basic {
    
  using safemath for uint256;
 
  mapping(address => uint256) balances;
 
  
  function transfer(address _to, uint256 _value) tokenison returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    transfer(msg.sender, _to, _value);
    return true;
  }
 
  
  function balanceof(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
 
}
 

contract standardtoken is erc20, basictoken {
 
  mapping (address => mapping (address => uint256)) allowed;
 
  
  function transferfrom(address _from, address _to, uint256 _value) tokenison returns (bool) {
    var _allowance = allowed[_from][msg.sender];
 
    
    
 
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    transfer(_from, _to, _value);
    return true;
  }
 
  
  function approve(address _spender, uint256 _value) returns (bool) {
 
    
    
    
    
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
 
    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }
 
  
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
   

    function increaseallowance(address spender, uint256 addedvalue) public returns (bool) {
        require(spender != address(0));

        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedvalue);
        approval(msg.sender, spender, allowed[msg.sender][spender]);

        return true;
    }



    

    function decreaseallowance(address spender, uint256 subtractedvalue) public returns (bool) {

        require(spender != address(0));

        allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedvalue);
        approval(msg.sender, spender, allowed[msg.sender][spender]);

        return true;

    }
 
}

contract huobirussiatoken is standardtoken {
    
  string public constant name = ;
   
  string public constant symbol = ;
    
  uint32 public constant decimals = 18;
 
  uint256 public initial_supply = 200000000 * 1 ether;
 
  function huobirussiatoken() {
    totalsupply = initial_supply;
    balances[msg.sender] = initial_supply;
  }
    
}
 
