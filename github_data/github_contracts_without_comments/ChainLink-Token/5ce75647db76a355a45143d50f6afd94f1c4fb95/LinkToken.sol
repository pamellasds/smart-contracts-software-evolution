pragma solidity ^0.4.8;


import ;
import ;
import ;


contract linktoken is standardtoken, standard223token {

  uint public constant totalsupply = 10**18;
  string public constant name = ;
  uint8 public constant decimals = 9;
  string public constant symbol = ;


  function linktoken()
  {
    balances[msg.sender] = totalsupply;
  }

  function transfer(address _to, uint _value)
  public validrecipient(_to)
  {
    super.transfer(_to, _value);
  }

  function approveandcall(address _to, uint _value, bytes _data)
  public
  {
    approve(_to, _value);
    if (!_to.call(_data))
      throw;
  }


  

  modifier validrecipient(address _recipient) {
    if (_recipient == address(0) || _recipient == address(this))
      throw;
    _;
  }

}
