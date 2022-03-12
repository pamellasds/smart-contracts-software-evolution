pragma solidity ^0.4.8;


import ;
import ;



contract basictoken is erc20basic {
  using safemath for uint256;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value)
  public returns (bool success) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceof(address _owner)
  constant returns (uint256 balance) {
    return balances[_owner];
  }

}
