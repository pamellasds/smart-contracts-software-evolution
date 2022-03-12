pragma solidity ^0.4.2;

contract tokensale {

  uint public fundinglimit;
  uint public starttime;
  address public recipient;

  event log(uint limit);

  function tokensale(
    address _recipient,
    uint _limit,
    uint _start
  ) {
    log(fundinglimit);
    fundinglimit = _limit;
    recipient = _recipient;
    starttime = _start;
  }

}
