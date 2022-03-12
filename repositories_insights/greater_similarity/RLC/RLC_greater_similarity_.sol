pragma solidity ^0.4.8;

contract tokenspender {
    function receiveapproval(address _from, uint256 _value, address _token, bytes _extradata);
}
pragma solidity ^0.4.8;

contract safemath {
  function safemul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safediv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safesub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a  b;
  }

  function safeadd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
pragma solidity ^0.4.8;

contract ownable {
  address public owner;

  function ownable() {
    owner = msg.sender;
  }

  modifier onlyowner() {
    if (msg.sender == owner)
      _;
  }

  function transferownership(address newowner) onlyowner {
    if (newowner != address(0)) owner = newowner;
  }

}
pragma solidity ^0.4.8;

contract erc20 {
  uint public totalsupply;
  function balanceof(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferfrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event transfer(address indexed from, address indexed to, uint value);
  event approval(address indexed owner, address indexed spender, uint value);
}
pragma solidity ^0.4.8;

import ;
import ;
import ;
import ;
contract rlc is erc20, safemath, ownable {

    
  string public name;       
  string public symbol;
  uint8 public decimals;    
  string public version = ;
  uint public initialsupply;
  uint public totalsupply;
  bool public locked;
  

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;


  

  function rlc() {
    initialsupply = 87000000000000000;
    totalsupply = initialsupply;
    balances[msg.sender] = initialsupply;
    name = ;        
    symbol = ;                       
    decimals = 9;                        
  }


  
  function refill(address _to, uint _value) onlyowner returns (bool) {
    balances[_to] = safeadd(balances[_to], _value);
    totalsupply = safeadd(totalsupply, _value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  
  function forceapprove(address _giver, address _spender, uint _value) onlyowner returns (bool) {
    allowed[_giver][_spender] = _value;
    approval(_giver, _spender, _value);
    return true;
  }

  
  function forceburn(address _toburn,uint256 _value) onlyowner returns (bool){
    balances[_toburn] = safesub(balances[_toburn], _value) ;
    totalsupply = safesub(totalsupply, _value);
    transfer(_toburn, 0x0, _value);
    return true;
  }


  function burn(uint256 _value) returns (bool){
    balances[msg.sender] = safesub(balances[msg.sender], _value) ;
    totalsupply = safesub(totalsupply, _value);
    transfer(msg.sender, 0x0, _value);
    return true;
  }

  function transfer(address _to, uint _value) returns (bool) {
    balances[msg.sender] = safesub(balances[msg.sender], _value);
    balances[_to] = safeadd(balances[_to], _value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  function transferfrom(address _from, address _to, uint _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = safeadd(balances[_to], _value);
    balances[_from] = safesub(balances[_from], _value);
    allowed[_from][msg.sender] = safesub(_allowance, _value);
    transfer(_from, _to, _value);
    return true;
  }

  function balanceof(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }

    
  function approveandcall(address _spender, uint256 _value, bytes _extradata){
      tokenspender spender = tokenspender(_spender);
      if (approve(_spender, _value)) {
          spender.receiveapproval(msg.sender, _value, this, _extradata);
      }
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}
