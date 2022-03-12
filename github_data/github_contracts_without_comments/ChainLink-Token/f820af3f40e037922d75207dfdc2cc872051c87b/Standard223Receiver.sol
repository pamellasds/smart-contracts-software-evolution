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

  function tokenfallback(address _sender, uint _value, bytes _data) {
    __istokenfallback = true;
    receivedtoken = receivedtoken(msg.sender, _sender, _value, _data, getsig(_data));
    if (!address(this).delegatecall(_data)) throw;
    
    __istokenfallback = false;
  }

  function getsig(bytes _data) private returns (bytes4 sig) {
    uint l = _data.length < 4 ? _data.length : 4;
    for (uint i = 0; i < l; i++) {
      sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (l  1  i))));
    }
  }

  bool __istokenfallback;

  modifier tokenpayable {
    if (!__istokenfallback) throw;
    _;
  }
}
