pragma solidity ^0.4.23;


contract ownablestorage {

  address public owner;

  constructor() internal {
    owner = msg.sender;
  }

}
