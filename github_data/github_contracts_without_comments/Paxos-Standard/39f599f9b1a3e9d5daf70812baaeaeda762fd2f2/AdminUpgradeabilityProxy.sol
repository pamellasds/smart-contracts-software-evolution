pragma solidity ^0.4.24;

import ;


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
