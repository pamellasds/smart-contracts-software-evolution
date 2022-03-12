pragma solidity ^0.4.8;



contract pullpayment {
  mapping(address => uint) public payments;

  
  function asyncsend(address dest, uint amount) internal {
    payments[dest] += amount;
  }

  
  function withdrawpayments() {
    address payee = msg.sender;
    uint payment = payments[payee];
    
    if (payment == 0) {
      throw;
    }

    if (this.balance < payment) {
      throw;
    }

    payments[payee] = 0;

    if (!payee.send(payment)) {
      throw;
    }
  }
}
