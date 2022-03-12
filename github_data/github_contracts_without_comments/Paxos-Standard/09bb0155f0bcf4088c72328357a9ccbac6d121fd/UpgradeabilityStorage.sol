pragma solidity ^0.4.24;


import ;










contract upgradeabilitystorage {
    
    
    
    
    bytes32 private constant implementation_slot = 0x7c1cded848eabd8a60d94bd67445d2326d086da486fef295645c7904d7dd00c2;


    
    function _implementation() internal view returns (address impl) {
        bytes32 slot = implementation_slot;
        assembly {
            impl := sload(slot)
        }
    }

    
    function _setimplementation(address newimplementation) internal {
        require(addressutils.iscontract(newimplementation), );

        bytes32 slot = implementation_slot;

        assembly {
            sstore(slot, newimplementation)
        }
    }
}
