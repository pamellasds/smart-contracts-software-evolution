pragma solidity ^0.4.18;

import ;
import ;
import ;
import ;

contract proxy is storage, delegateproxy, ownable {

  event upgrade(address indexed newcontract, bytes initializedwith);
  event ownerupdate(address _prevowner, address _newowner);

  function proxy() public {
    proxyowner = msg.sender;
    owner = msg.sender;
  }

  
  
  modifier onlyproxyowner() {
    require(msg.sender == proxyowner);
    _;
  }

  function transferownership(address _newowner) public onlyproxyowner {
    require(_newowner != address(0));
    require(_newowner != proxyowner);
    proxyowner = _newowner;
  }

  
  
  function upgrade(iapplication newcontract, bytes data) public onlyproxyowner {
    currentcontract = newcontract;
    iapplication(this).initialize(data);

    upgrade(newcontract, data);
  }

  
  
  function () payable public {
    require(currentcontract != 0); 
    delegatedfwd(currentcontract, msg.data);
  }
}
