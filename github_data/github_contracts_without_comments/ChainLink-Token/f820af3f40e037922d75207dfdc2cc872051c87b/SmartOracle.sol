pragma solidity ^0.4.8;


contract smartoracle {

  address public owner;

  function smartoracle()
  {
    owner = msg.sender;
  }

}
