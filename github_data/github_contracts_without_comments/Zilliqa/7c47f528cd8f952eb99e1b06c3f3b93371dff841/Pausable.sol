pragma solidity ^0.4.18;



import ;



contract pausable is ownable {
  event pausepublic(bool newstate);
  event pauseowneradmin(bool newstate);

  bool public pausedpublic = true;
  bool public pausedowneradmin = false;

  address public admin;

  
  modifier whennotpaused() {
    if(pausedpublic) {
      if(!pausedowneradmin) {
        require(msg.sender == admin || msg.sender == owner);
      } else {
        revert();
      }
    }
    _;
  }

  
  function pause(bool newpausedpublic, bool newpausedowneradmin) onlyowner public {
    require(!(newpausedpublic == false && newpausedowneradmin == true));

    pausedpublic = newpausedpublic;
    pausedowneradmin = newpausedowneradmin;

    pausepublic(newpausedpublic);
    pauseowneradmin(newpausedowneradmin);
  }
}
