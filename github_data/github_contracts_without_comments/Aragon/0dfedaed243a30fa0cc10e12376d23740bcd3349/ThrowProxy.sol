pragma solidity ^0.4.8;

import ;




contract throwproxy {
  address public target;
  bytes data;

  function throwproxy(address _target) {
    target = _target;
  }

  
  function() {
    data = msg.data;
  }

  function assertthrows(string msg) {
    assert.isfalse(execute(), msg);
  }

  function assertitdoesntthrow(string msg) {
    assert.istrue(execute(), msg);
  }

  function execute() returns (bool) {
    return target.call(data);
  }
}
