pragma solidity ^0.4.8;



contract erc20basic {
  uint public totalsupply;
  function balanceof(address who) constant returns (uint);
  function transfer(address to, uint value);
  event transfer(address indexed from, address indexed to, uint value);
}
