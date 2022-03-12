pragma solidity ^0.4.8;

import ;

contract networkmock {
  function proxypayment(address _owner) payable returns (bool) {
    return false;
  }

  function ontransfer(address _from, address _to, uint _amount) returns (bool) {
    return false;
  }

  function onapprove(address _owner, address _spender, uint _amount) returns (bool) {
    return false;
  }
}
