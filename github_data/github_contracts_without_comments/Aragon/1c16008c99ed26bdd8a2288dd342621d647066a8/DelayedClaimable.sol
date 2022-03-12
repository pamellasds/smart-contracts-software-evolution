pragma solidity ^0.4.8;


import ;
import ;



contract delayedclaimable is ownable, claimable {

  uint public end;
  uint public start;

  function setlimits(uint _start, uint _end) onlyowner {
    if (_start > _end)
        throw;
    end = _end;
    start = _start;
  }

  function claimownership() onlypendingowner {
    if ((block.number > end) || (block.number < start))
        throw;
    owner = pendingowner;
    pendingowner = 0x0;
    end = 0;
  }

}
