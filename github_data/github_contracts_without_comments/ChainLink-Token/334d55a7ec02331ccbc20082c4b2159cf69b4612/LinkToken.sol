pragma solidity ^0.4.11;


import ;
import ;


contract linktoken is standard223token {

  uint public constant totalsupply = 10**18;
  string public constant name = ;
  uint8 public constant decimals = 9;
  string public constant symbol = ;

  function linktoken()
  public
  {
    balances[msg.sender] = totalsupply;
  }

  
  function transfer(address _to, uint _value)
  public validrecipient(_to) returns (bool success)
  {
    super.transfer(_to, _value);
  }


  

  modifier validrecipient(address _recipient) {
    require(_recipient != address(0));
    _;
  }

}
