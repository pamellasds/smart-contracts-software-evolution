pragma solidity ^0.4.8;


import ;
import ;



contract standardtoken is erc20, safemath {

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safesub(balances[msg.sender], _value);
    balances[_to] = safeadd(balances[_to], _value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  function transferfrom(address _from, address _to, uint _value) returns (bool success) {
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

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}
