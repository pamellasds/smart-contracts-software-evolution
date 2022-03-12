pragma solidity ^0.4.8;

 

import ;

contract standard223receiver is erc223receiver {
  receivedtoken receivedtoken;

  struct receivedtoken {
    address addr;
    address sender;
    uint256 value;
    bytes data;
    bytes4 sig;
  }

  function tokenfallback(address _sender, uint _value, bytes _data)
  public returns (bool success) {
    __istokenfallback = true;
    if (!address(this).delegatecall(_data)) throw;
    __istokenfallback = false;
    return true;
  }


  

  bool private __istokenfallback;

  function getsig(bytes _data)
  private returns (bytes4 sig) {
    uint l = _data.length < 4 ? _data.length : 4;
    for (uint i = 0; i < l; i++) {
      sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (l  1  i))));
    }
  }

  modifier tokenpayable {
    if (!__istokenfallback) throw;
    _;
  }
}
