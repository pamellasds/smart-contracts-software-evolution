pragma solidity ^0.4.8;


import ;
import ;



contract basictoken is erc20basic, safemath {

  mapping(address => uint) balances;

  function transfer(address _to, uint _value) {
    balances[msg.sender] = safesub(balances[msg.sender], _value);
    balances[_to] = safeadd(balances[_to], _value);
    transfer(msg.sender, _to, _value);
  }

  function balanceof(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
  
}
