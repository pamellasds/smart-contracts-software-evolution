pragma solidity ^0.4.18;

import ;

contract ownable is storage {

  event ownerupdate(address _prevowner, address _newowner);

  function bytestoaddress (bytes b) pure public returns (address) {
    uint result = 0;
    for (uint i = b.length1; i+1 > 0; i) {
      uint c = uint(b[i]);
      uint to_inc = c * ( 16 ** ((b.length  i1) * 2));
      result += to_inc;
    }
    return address(result);
  }

  modifier onlyowner {
    assert(msg.sender == owner);
    _;
  }

  function transferownership(address _newowner) public onlyowner {
    require(_newowner != owner);
    owner = _newowner;
  }
}
