pragma solidity ^0.4.24;
pragma experimental ;


import ;



contract proxy is upgradeabilitystorage {
    
    constructor(address _impl) public {
        _setimplementation(_impl);
    }


    
    function () external payable {
        _delegate();
    }

    
    function _delegate() internal {
        address impl = _implementation();

        assembly {
            
            
            
            calldatacopy(0, 0, calldatasize)

            
            
            let result := delegatecall(gas, impl, 0, calldatasize, 0, 0)

            
            returndatacopy(0, 0, returndatasize)

            switch result
            
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }
}
