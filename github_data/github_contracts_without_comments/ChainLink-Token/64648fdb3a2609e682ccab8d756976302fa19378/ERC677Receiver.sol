pragma solidity ^0.4.11;



contract erc677receiver {
  function receiveapproval(address from, uint256 amount, address token, bytes data) returns (bool success);
  function receivetokentransfer(address from, uint256 amount, bytes data) returns (bool success);
}
