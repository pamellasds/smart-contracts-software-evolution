pragma solidity ^0.4.8;

import ;

contract erc677 is linkerc20 {
  function transferandcall(address to, uint value, bytes data) returns (bool success);

  event transfer(address indexed from, address indexed to, uint value, bytes data);
}
