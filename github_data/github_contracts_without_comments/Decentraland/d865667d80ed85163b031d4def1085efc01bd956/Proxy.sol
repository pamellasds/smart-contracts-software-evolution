pragma solidity ^0.4.18;

import ;

import ;

import ;

contract proxy is proxystorage, delegateproxy {

  event upgrade(address indexed newcontract, bytes initializedwith);

  function upgrade(iapplication newcontract, bytes data) public {
    currentcontract = newcontract;
    newcontract.initialize(data);

    upgrade(newcontract, data);
  }

  function () payable public {
    require(currentcontract != 0); 
    delegatedfwd(currentcontract, msg.data);
  }
}
