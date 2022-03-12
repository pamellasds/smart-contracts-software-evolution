pragma solidity ^0.4.18;

contract ownablestorage {

  address public owner;

  function ownablestorage() internal {
    owner = msg.sender;
  }

}
