pragma solidity ^0.4.8;

contract erc20 {
  uint public totalsupply;
  function balanceof(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferfrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event transfer(address indexed from, address indexed to, uint value);
  event approval(address indexed owner, address indexed spender, uint value);
}
