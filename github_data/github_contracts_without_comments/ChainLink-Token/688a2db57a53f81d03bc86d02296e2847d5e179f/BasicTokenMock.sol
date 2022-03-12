pragma solidity ^0.4.8;


import ;



contract basictokenmock is linkbasictoken {

  function basictokenmock(address initialaccount, uint initialbalance)
  {
    balances[initialaccount] = initialbalance;
    totalsupply = initialbalance;
  }

}
