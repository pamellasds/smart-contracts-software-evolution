pragma solidity ^0.4.8;


import ;
import ;
import ;


contract linktoken is standardtoken {

  uint public constant totalsupply = 10**18;
  string public constant name = ;
  uint8 public constant decimals = 9;
  string public constant symbol = ;

  function linktoken()
  {
    balances[msg.sender] = totalsupply;
  }

}
