pragma solidity ^0.4.18;

import ;



contract tokenmock is token {
  function tokenmock(address _initialaccount, uint256 _initialbalance) public {
    balances[_initialaccount] = _initialbalance;
    totalsupply = _initialbalance;
  }
}