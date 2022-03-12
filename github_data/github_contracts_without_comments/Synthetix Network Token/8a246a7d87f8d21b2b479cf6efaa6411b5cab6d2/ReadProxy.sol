pragma solidity ^0.5.16;

import ;





contract readproxy is owned {
    address public target;

    constructor(address _owner) public owned(_owner) {}

    function settarget(address _target) external onlyowner {
        target = _target;
        emit targetupdated(target);
    }

    function() external {
        
        
        assembly {
            calldatacopy(0, 0, calldatasize)

            
            let result := staticcall(gas, sload(target_slot), 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)

            if iszero(result) {
                revert(0, returndatasize)
            }
            return(0, returndatasize)
        }
    }

    event targetupdated(address newtarget);
}
