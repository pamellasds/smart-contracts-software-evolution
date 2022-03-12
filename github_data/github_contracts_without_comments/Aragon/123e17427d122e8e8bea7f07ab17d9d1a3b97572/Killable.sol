pragma solidity ^0.4.8;


import ;



contract killable is ownable {
  function kill() onlyowner {
    selfdestruct(owner);
  }
}
