pragma solidity ^0.4.24;

import ;
import ;


contract upgradeabilityproxy is proxy {
    
    event upgraded(address implementation);

    
    bytes32 private constant implementation_slot = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

    
    constructor(address _implementation) public {
        assert(implementation_slot == keccak256());

        _setimplementation(_implementation);
    }

    
    function _implementation() internal view returns (address impl) {
        bytes32 slot = implementation_slot;
        assembly {
            impl := sload(slot)
        }
    }

    
    function _upgradeto(address newimplementation) internal {
        _setimplementation(newimplementation);
        emit upgraded(newimplementation);
    }

    
    function _setimplementation(address newimplementation) private {
        require(addressutils.iscontract(newimplementation), );

        bytes32 slot = implementation_slot;

        assembly {
            sstore(slot, newimplementation)
        }
    }
}
