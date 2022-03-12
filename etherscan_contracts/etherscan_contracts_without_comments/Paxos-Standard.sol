

pragma solidity ^0.4.24;




contract proxy {
    
    function () payable external {
        _fallback();
    }

    
    function _implementation() internal view returns (address);

    
    function _delegate(address implementation) internal {
        assembly {
        
        
        
            calldatacopy(0, 0, calldatasize)

        
        
            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

        
            returndatacopy(0, 0, returndatasize)

            switch result
            
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }

    
    function _willfallback() internal {
    }

    
    function _fallback() internal {
        _willfallback();
        _delegate(_implementation());
    }
}




library addressutils {

    
    function iscontract(address addr) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}




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




contract adminupgradeabilityproxy is upgradeabilityproxy {
    
    event adminchanged(address previousadmin, address newadmin);

    
    bytes32 private constant admin_slot = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

    
    modifier ifadmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    
    constructor(address _implementation) upgradeabilityproxy(_implementation) public {
        assert(admin_slot == keccak256());

        _setadmin(msg.sender);
    }

    
    function admin() external view ifadmin returns (address) {
        return _admin();
    }

    
    function implementation() external view ifadmin returns (address) {
        return _implementation();
    }

    
    function changeadmin(address newadmin) external ifadmin {
        require(newadmin != address(0), );
        emit adminchanged(_admin(), newadmin);
        _setadmin(newadmin);
    }

    
    function upgradeto(address newimplementation) external ifadmin {
        _upgradeto(newimplementation);
    }

    
    function upgradetoandcall(address newimplementation, bytes data) payable external ifadmin {
        _upgradeto(newimplementation);
        require(address(this).call.value(msg.value)(data));
    }

    
    function _admin() internal view returns (address adm) {
        bytes32 slot = admin_slot;
        assembly {
            adm := sload(slot)
        }
    }

    
    function _setadmin(address newadmin) internal {
        bytes32 slot = admin_slot;

        assembly {
            sstore(slot, newadmin)
        }
    }

    
    function _willfallback() internal {
        require(msg.sender != _admin(), );
        super._willfallback();
    }
}