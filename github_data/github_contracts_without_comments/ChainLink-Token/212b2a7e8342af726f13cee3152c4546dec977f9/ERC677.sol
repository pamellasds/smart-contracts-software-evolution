pragma solidity ^0.6.0;

import ;

abstract contract erc677 is ierc20 {
  function transferandcall(address to, uint value, bytes memory data) public virtual returns (bool success);

  event transfer(address indexed from, address indexed to, uint value, bytes data);
}
