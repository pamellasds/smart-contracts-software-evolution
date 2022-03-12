pragma solidity ^0.4.8;


import ;



contract pausable is ownable {
  bool public stopped;

  modifier stopinemergency {
    if (!stopped) {
      _;
    }
  }
  
  modifier onlyinemergency {
    if (stopped) {
      _;
    }
  }

  
  function emergencystop() external onlyowner {
    stopped = true;
  }

  
  function release() external onlyowner onlyinemergency {
    stopped = false;
  }

}
