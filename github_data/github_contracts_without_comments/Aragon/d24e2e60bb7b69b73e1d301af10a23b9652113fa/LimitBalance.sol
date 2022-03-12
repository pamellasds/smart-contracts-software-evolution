pragma solidity ^0.4.8;



contract limitbalance {

  uint public limit;

  function limitbalance(uint _limit) {
    limit = _limit;
  }

  modifier limitedpayable() { 
    if (this.balance > limit) {
      throw;
    }
    _;
    
  }

}
