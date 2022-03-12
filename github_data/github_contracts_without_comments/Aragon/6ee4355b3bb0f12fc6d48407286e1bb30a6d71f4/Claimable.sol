pragma solidity ^0.4.0;


import ;



contract claimable is ownable {
  address public pendingowner;

  modifier onlypendingowner() {
    if (msg.sender != pendingowner) {
      throw;
    }
    _;
  }

  function transferownership(address newowner) onlyowner {
    pendingowner = newowner;
  }

  function claimownership() onlypendingowner {
    owner = pendingowner;
    pendingowner = 0x0;
  }

}
