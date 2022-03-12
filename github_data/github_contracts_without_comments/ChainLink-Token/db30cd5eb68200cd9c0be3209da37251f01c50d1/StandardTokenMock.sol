pragma solidity ^0.4.8;


import ;


contract standardtokenmock is linkstandardtoken {

  function standardtokenmock(address initialaccount, uint initialbalance)
  {
    balances[initialaccount] = initialbalance;
    totalsupply = initialbalance;
  }

}
