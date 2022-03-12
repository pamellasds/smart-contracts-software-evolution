pragma solidity ^0.4.24;


contract reputationtoken {

  function getreputation() public returns (uint256);

  function buy(uint256 _amount) public returns (bool);

  function sell(uint256 _amount) public returns (bool);

  event bought(address indexed who, uint256 amount);

  event sold(address indexed who, uint256 amount);
  
}
