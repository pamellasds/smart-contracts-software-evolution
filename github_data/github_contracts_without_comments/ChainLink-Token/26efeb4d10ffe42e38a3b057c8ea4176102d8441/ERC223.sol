pragma solidity ^0.4.8;

import ;

contract erc223 is erc20 {
  function transfer(address to, uint value, bytes data) returns (bool success);

  event transfer(address indexed from, address indexed to, uint value, bytes data);
}
