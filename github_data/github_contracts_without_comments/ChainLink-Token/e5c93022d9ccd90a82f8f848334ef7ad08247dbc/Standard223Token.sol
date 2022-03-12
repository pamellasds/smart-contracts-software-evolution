pragma solidity ^0.4.8;


import ;
import ;
import ;


contract standard223token is erc223, standardtoken {

  event log(address to, uint amount);

  function unsafetransfer(address _to, uint _value)
  public returns (bool success)
  {
    return super.transfer(_to, _value);
  }

  function transfer(address _to, uint _value, bytes _data)
  public returns (bool success)
  {
    unsafetransfer(_to, _value);
    if (iscontract(_to))
      contractfallback(_to, _value, _data);
    return true;
  }

  function transfer(address _to, uint _value)
  public returns (bool success)
  {
    return transfer(_to, _value, new bytes(0));
  }

  

  function contractfallback(address _to, uint _value, bytes _data)
  private
  {
    erc223receiver reciever = erc223receiver(_to);
    reciever.tokenfallback(msg.sender, _value, _data);
  }

  function iscontract(address _addr)
  private returns (bool iscontract)
  {
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}
