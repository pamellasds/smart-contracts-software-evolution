pragma solidity ^0.4.8;


import ;



contract erc20 is erc20basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferfrom(address from, address to, uint256 value);
  function approve(address spender, uint256 value);
  event approval(address indexed owner, address indexed spender, uint256 value);
}
