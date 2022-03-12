pragma solidity ^0.4.8;

import ;
import ;

contract tokenreceivermock is approveandcallfallback {
  bytes public extradata;
  uint public tokenbalance;

  function receiveapproval(address _from, uint256 _amount, address _token, bytes _data) {
    standardtoken(_token).transferfrom(_from, this, _amount);

    tokenbalance = standardtoken(_token).balanceof(this);
    extradata = _data;
  }
}
