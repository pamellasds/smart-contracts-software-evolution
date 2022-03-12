pragma solidity ^0.4.11;



contract erc677receiver {
  function receiveapproval(address from, uint256 _amount, address _token, bytes _data) returns (bool _success);
}
