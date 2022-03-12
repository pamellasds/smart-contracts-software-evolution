pragma solidity ^0.4.24;


contract reputationtoken {

  function getreputation() public returns (uint256);

  function long(uint256 _amount) public returns (bool);

  function short(uint256 _amount) public returns (bool);

  event wentlong(address indexed who, uint256 amount);

  event wentshort(address indexed who, uint256 amount);
  
}
