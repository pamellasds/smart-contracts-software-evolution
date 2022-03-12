pragma solidity ^0.4.15;

import ;

contract fakeland is land {
  function create(uint tokenid, address owner) {
    _addtokento(owner, tokenid);
    totaltokens++;

    tokencreated(tokenid, owner, );
  }
}

