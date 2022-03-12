pragma solidity ^0.4.11;



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
    require(msg.sender == owner);
    _;
  }
}
