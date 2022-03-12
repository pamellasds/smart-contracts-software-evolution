pragma solidity ^0.4.8;



contract ownable {
  address public owner;


  
  function ownable()
  {
    owner = msg.sender;
  }


  
  function transferownership(address newowner)
  onlyowner
  {
    if (newowner != address(0)) {
      owner = newowner;
    }
  }


  

  
  modifier onlyowner()
  {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }
}
