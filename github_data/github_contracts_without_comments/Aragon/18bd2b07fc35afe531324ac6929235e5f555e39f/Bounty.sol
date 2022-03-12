pragma solidity ^0.4.8;


import ;
import ;



contract bounty is pullpayment, killable {
  bool public claimed;
  mapping(address => address) public researchers;

  event targetcreated(address createdaddress);

  function() payable {
    if (claimed) {
      throw;
    }
  }

  function createtarget() returns(target) {
    target target = target(deploycontract());
    researchers[target] = msg.sender;
    targetcreated(target);
    return target;
  }

  function deploycontract() internal returns(address);

  function claim(target target) {
    address researcher = researchers[target];
    if (researcher == 0) {
      throw;
    }
    
    if (target.checkinvariant()) {
      throw;
    }
    asyncsend(researcher, this.balance);
    claimed = true;
  }

}



contract target {
  function checkinvariant() returns(bool);
}

