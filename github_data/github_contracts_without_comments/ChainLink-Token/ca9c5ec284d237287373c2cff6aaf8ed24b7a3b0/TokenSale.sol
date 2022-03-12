pragma solidity ^0.4.2;

contract tokensale {

  uint public fundinglimit;
  uint public starttime;
  address public recipient;

  event purchase(address purchaser, uint amount);

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

  function phasethreeend()
  constant returns (uint) {
    return starttime + 4 weeks;
  }

  function ()
  payable ensurestarted {
    if (recipient.send(msg.value)) {
      purchase(msg.sender, msg.value);
    }
  }


  

  modifier ensurestarted() {
    if (block.timestamp < starttime) {
      throw;
    } else {
      _;
    }
  }

}
