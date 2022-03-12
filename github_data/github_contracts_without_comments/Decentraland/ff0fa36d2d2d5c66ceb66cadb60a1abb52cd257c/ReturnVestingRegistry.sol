pragma solidity ^0.4.15;

import ;

contract returnvestingregistry is ownable {

  mapping (address => address) public returnaddress;

  function record(address from, address to) onlyowner public {
    require(from != 0);

    returnaddress[from] = to;
  }
}
