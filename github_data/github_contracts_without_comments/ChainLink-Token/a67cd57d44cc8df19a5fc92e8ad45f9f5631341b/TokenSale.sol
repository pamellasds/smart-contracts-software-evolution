pragma solidity ^0.4.8;

import ;

contract tokensale {
  using safemath for uint;

  uint public fundinglimit;
  uint public starttime;
  address public recipient;

  event purchase(address purchaser, uint paid, uint received);

  function tokensale(
    address _recipient,
    uint _limit,
    uint _start
  ) {
    fundinglimit = _limit;
    recipient = _recipient;
    starttime = _start;
  }

  function phaseoneend()
  constant returns (uint) {
    return starttime + 1 weeks;
  }

  function phasetwoend()
  constant returns (uint) {
    return starttime + 2 weeks;
  }

  function endtime()
  constant returns (uint) {
    return starttime + 4 weeks;
  }

  function ()
  payable ensurestarted {
    if (recipient.send(msg.value)) {
      purchase(msg.sender, msg.value, amountreceived());
    }
  }


  

  function amountreceived()
  private returns (uint) {
    if (block.timestamp <= phaseoneend()) {
      return msg.value.div(10**15);
    } else if (block.timestamp <= phasetwoend()) {
      return msg.value.times(75).div(10**17);
    } else {
      return msg.value.times(50).div(10**17);
    }
  }


  

  modifier ensurestarted() {
    if (block.timestamp < starttime || block.timestamp > endtime()) {
      throw;
    } else {
      _;
    }
  }

}
