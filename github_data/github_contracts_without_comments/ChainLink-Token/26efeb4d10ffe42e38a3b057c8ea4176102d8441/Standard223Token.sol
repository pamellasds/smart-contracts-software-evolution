pragma solidity ^0.4.11;


import ;
import ;
import ;


contract standard223token is erc223, standardtoken {

  
  function transfer(address _to, uint _value, bytes _data)
  public returns (bool success)
  {
    super.transfer(_to, _value);
    transfer(msg.sender, _to, _value, _data);
    if (iscontract(_to)) {
      contractfallback(_to, _value, _data);
    }
    return true;
  }

  

  function contractfallback(address _to, uint _value, bytes _data)
  private
  {
    erc223receiver receiver = erc223receiver(_to);
    receiver.tokenfallback(msg.sender, _value, _data);
  }

  function iscontract(address _addr)
  private returns (bool hascode)
  {
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}
