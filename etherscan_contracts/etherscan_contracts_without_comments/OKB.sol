pragma solidity ^0.4.24;

import ;



contract ownedupgradeabilityproxy is upgradeabilityproxy {
  
  event proxyownershiptransferred(address previousowner, address newowner);

  
  bytes32 private constant proxyownerposition = keccak256();

  
  constructor() public {
    setupgradeabilityowner(msg.sender);
  }

  
  modifier onlyproxyowner() {
    require(msg.sender == proxyowner());
    _;
  }

  
  function proxyowner() public view returns (address owner) {
    bytes32 position = proxyownerposition;
    assembly {
      owner := sload(position)
    }
  }

  
  function setupgradeabilityowner(address newproxyowner) internal {
    bytes32 position = proxyownerposition;
    assembly {
      sstore(position, newproxyowner)
    }
  }

  
  function transferproxyownership(address newowner) public onlyproxyowner {
    require(newowner != address(0));
    emit proxyownershiptransferred(proxyowner(), newowner);
    setupgradeabilityowner(newowner);
  }

  
  function upgradeto(address implementation) public onlyproxyowner {
    _upgradeto(implementation);
  }

  
  function upgradetoandcall(address implementation, bytes data) payable public onlyproxyowner {
    upgradeto(implementation);
    require(implementation.delegatecall(data));
}
}
pragma solidity ^0.4.24;

library address {
    
    function iscontract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
pragma solidity ^0.4.24;


contract proxy {
  
  function implementation() public view returns (address);

  
  function () payable public {
    address _impl = implementation();
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}
pragma solidity ^0.4.24;

import ;
import ;



contract upgradeabilityproxy is proxy {
  
  event upgraded(address indexed implementation);

  
  bytes32 private constant implementationposition = keccak256();

  
  constructor() public {}

  
  function implementation() public view returns (address impl) {
    bytes32 position = implementationposition;
    assembly {
      impl := sload(position)
    }
  }

  
  function setimplementation(address newimplementation) internal {
    require(address.iscontract(newimplementation),);
    bytes32 position = implementationposition;
    assembly {
      sstore(position, newimplementation)
    }
  }

  
  function _upgradeto(address newimplementation) internal {
    address currentimplementation = implementation();
    require(currentimplementation != newimplementation);
    setimplementation(newimplementation);
    emit upgraded(newimplementation);
  }
}