pragma solidity ^0.4.11;



contract ownable {
  address public owner;

  event ownershiptransferred(address indexed previousowner, address indexed newowner);


  
  function ownable() {
    owner = msg.sender;
  }


  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferownership(address newowner) onlyowner public {
    require(newowner != address(0));
    ownershiptransferred(owner, newowner);
    owner = newowner;
  }

}