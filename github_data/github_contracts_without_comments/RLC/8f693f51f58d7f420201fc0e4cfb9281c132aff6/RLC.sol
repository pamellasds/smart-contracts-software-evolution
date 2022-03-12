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


  

  function faucetrlc() {

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
