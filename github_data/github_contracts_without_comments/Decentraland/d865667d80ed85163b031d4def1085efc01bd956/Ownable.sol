pragma solidity ^0.4.18;

import ;

contract ownable is storage {

  event ownerupdate(address _prevowner, address _newowner);

  modifier onlyowner {
    assert(msg.sender == owner);
    _;
  }

  function initialize(bytes) public {
  }

  function transferownership(address _newowner) public onlyowner {
    require(_newowner != owner);
    owner = _newowner;
  }
}
