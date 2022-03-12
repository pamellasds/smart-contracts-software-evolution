pragma solidity ^0.4.4;

contract smartoracle {

  address public owner;

  function smartoracle() {
    owner = msg.sender;
  }

}
