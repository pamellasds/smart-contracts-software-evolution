pragma solidity ^0.6.0;

import ;
import ;
import ;

abstract contract erc677token is erc20, erc677 {
  
  function transferandcall(address _to, uint _value, bytes memory _data)
    public
    override
    virtual
    returns (bool success)
  {
    super.transfer(_to, _value);
    emit transfer(msg.sender, _to, _value, _data);
    if (iscontract(_to)) {
      contractfallback(_to, _value, _data);
    }
    return true;
  }


  

  function contractfallback(address _to, uint _value, bytes memory _data)
    private
  {
    erc677receiver receiver = erc677receiver(_to);
    receiver.ontokentransfer(msg.sender, _value, _data);
  }

  function iscontract(address _addr)
    private
    view
    returns (bool hascode)
  {
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}
