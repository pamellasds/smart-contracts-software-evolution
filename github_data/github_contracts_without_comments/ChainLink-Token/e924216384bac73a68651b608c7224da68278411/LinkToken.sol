pragma solidity ^0.4.11;


import ;
import ;


contract linktoken is standardtoken {

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
  public validrecipient(_to)
  {
    super.transfer(_to, _value);
  }

  
  function approveandcall(address _recipient, uint _value, bytes _data)
  public
  {
    approve(_recipient, _value);
    require(_recipient.call(_data));
  }


  

  modifier validrecipient(address _recipient) {
    require(_recipient != address(0) && _recipient != address(this));
    _;
  }

}
