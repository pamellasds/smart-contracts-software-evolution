pragma solidity ^0.4.8;

import ;
import ;




contract anplaceholder is controller {
  address public sale;
  ant public token;

  function anplaceholder(address _sale, address _ant) {
    sale = _sale;
    token = ant(_ant);
  }

  function changecontroller(address network) {
    if (msg.sender != sale) throw;
    token.changecontroller(network);
    suicide(network);
  }

  
  function proxypayment(address _owner) payable returns (bool) {
    return false;
  }

  function ontransfer(address _from, address _to, uint _amount) returns (bool) {
    return true;
  }

  function onapprove(address _owner, address _spender, uint _amount) returns (bool) {
    return true;
  }
}
