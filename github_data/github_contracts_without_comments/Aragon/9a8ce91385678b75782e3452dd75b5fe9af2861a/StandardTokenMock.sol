pragma solidity ^0.4.8;


import ;


contract standardtokenmock is standard23token {
  function standardtokenmock(address initialaccount, uint initialbalance) {
    balances[initialaccount] = initialbalance;
    totalsupply = initialbalance;
  }
}
