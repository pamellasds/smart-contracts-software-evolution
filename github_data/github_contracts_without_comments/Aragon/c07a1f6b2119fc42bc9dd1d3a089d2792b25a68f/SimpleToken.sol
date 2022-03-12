pragma solidity ^0.4.8;


import ;



contract simpletoken is standardtoken {

  string public name = ;
  string public symbol = ;
  uint public decimals = 18;
  uint public initial_supply = 10000;
  
  function simpletoken() {
    totalsupply = initial_supply;
    balances[msg.sender] = initial_supply;
  }

}
