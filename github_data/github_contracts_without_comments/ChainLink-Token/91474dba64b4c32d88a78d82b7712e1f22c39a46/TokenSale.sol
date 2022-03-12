pragma solidity ^0.4.8;

import ;
import ;
import ;

contract tokensale is ownable {
  using safemath for uint;

  uint public fundinglimit;
  uint public starttime;
  uint public fundingreceived;
  uint public phaseoneend;
  uint public phasetwoend;
  uint public endtime;
  address public recipient;
  linktoken public token;

  event purchase(address purchaser, uint paid, uint received);

  function tokensale(
    uint _limit,
    uint _start
  ) {
    fundinglimit = _limit;
    starttime = _start;
    phaseoneend = _start + 1 weeks;
    phasetwoend = _start + 2 weeks;
    endtime = _start + 4 weeks;
    token = new linktoken();
  }

  function ()
  payable ensurestarted {
    bool underlimit = msg.value + fundingreceived <= fundinglimit;
    if (underlimit && owner.send(msg.value)) {
      fundingreceived += msg.value;
      token.transfer(msg.sender, amountreceived());
    } else {
      throw;
    }
  }


  

  function amountreceived()
  private returns (uint) {
    if (block.timestamp <= phaseoneend) {
      return msg.value.div(10**15);
    } else if (block.timestamp <= phasetwoend) {
      return msg.value.mul(75).div(10**17);
    } else {
      return msg.value.mul(50).div(10**17);
    }
  }


  

  modifier ensurestarted() {
    if (block.timestamp < starttime || block.timestamp > endtime) {
      throw;
    } else {
      _;
    }
  }

}
