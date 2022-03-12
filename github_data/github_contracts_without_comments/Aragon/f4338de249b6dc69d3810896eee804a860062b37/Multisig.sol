pragma solidity ^0.4.8;



contract multisig {
  

  
  
  event deposit(address _from, uint value);
  
  event singletransact(address owner, uint value, address to, bytes data);
  
  event multitransact(address owner, bytes32 operation, uint value, address to, bytes data);
  
  event confirmationneeded(bytes32 operation, address initiator, uint value, address to, bytes data);


  

  
  function changeowner(address _from, address _to) external;
  function execute(address _to, uint _value, bytes _data) external returns (bytes32);
  function confirm(bytes32 _h) returns (bool);
}

