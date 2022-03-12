pragma solidity ^0.4.15;

import ;

contract fakeland is land {
  function fakeland() {
    land(this);
  }

  function create(uint tokenid, address owner) {
    assignnewparcel(owner, tokenid, );
  }
}

