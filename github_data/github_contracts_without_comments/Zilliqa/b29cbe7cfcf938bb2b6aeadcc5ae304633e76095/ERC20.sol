pragma solidity ^0.4.18;


import ;



contract erc20 is erc20basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferfrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event approval(address indexed owner, address indexed spender, uint256 value);
}
