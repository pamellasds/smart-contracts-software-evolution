pragma solidity ^0.4.11;


import ;


contract linkreceiver {

  bool public callbackcalled;
  uint public tokensreceived;


  function callbackwithoutwithdrawl()
  public
  {
    callbackcalled = true;
  }

  function callbackwithwithdrawl(uint _value)
  public
  {
    callbackcalled = true;
    tokensreceived = _value;
    erc20 token = erc20(msg.sender);
    token.transferfrom(tx.origin, this, _value);
  }


}
