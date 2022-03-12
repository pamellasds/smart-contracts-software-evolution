

pragma solidity ^0.4.23;






contract proxy {
    
    
    function implementation() public view returns (address);

    
    function() external payable {
        address _impl = implementation();
        require(_impl != address(0), );
        
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




contract upgradeabilityproxy is proxy {
    
    event upgraded(address indexed implementation);

    
    bytes32 private constant implementationposition = keccak256();

    
    function implementation() public view returns (address impl) {
        bytes32 position = implementationposition;
        assembly {
          impl := sload(position)
        }
    }

    
    function _setimplementation(address newimplementation) internal {
        bytes32 position = implementationposition;
        assembly {
          sstore(position, newimplementation)
        }
    }

    
    function _upgradeto(address newimplementation) internal {
        address currentimplementation = implementation();
        require(currentimplementation != newimplementation);
        _setimplementation(newimplementation);
        emit upgraded(newimplementation);
    }
}




contract ownedupgradeabilityproxy is upgradeabilityproxy {
    
    event proxyownershiptransferred(address indexed previousowner, address indexed newowner);

    
    event newpendingowner(address currentowner, address pendingowner);
    
    
    bytes32 private constant proxyownerposition = keccak256();
    bytes32 private constant pendingproxyownerposition = keccak256();

    
    constructor() public {
        _setupgradeabilityowner(msg.sender);
    }

    
    modifier onlyproxyowner() {
        require(msg.sender == proxyowner(), );
        _;
    }

    
    modifier onlypendingproxyowner() {
        require(msg.sender == pendingproxyowner(), );
        _;
    }

    
    function proxyowner() public view returns (address owner) {
        bytes32 position = proxyownerposition;
        assembly {
            owner := sload(position)
        }
    }

    
    function pendingproxyowner() public view returns (address pendingowner) {
        bytes32 position = pendingproxyownerposition;
        assembly {
            pendingowner := sload(position)
        }
    }

    
    function _setupgradeabilityowner(address newproxyowner) internal {
        bytes32 position = proxyownerposition;
        assembly {
            sstore(position, newproxyowner)
        }
    }

    
    function _setpendingupgradeabilityowner(address newpendingproxyowner) internal {
        bytes32 position = pendingproxyownerposition;
        assembly {
            sstore(position, newpendingproxyowner)
        }
    }

    
    function transferproxyownership(address newowner) external onlyproxyowner {
        require(newowner != address(0));
        _setpendingupgradeabilityowner(newowner);
        emit newpendingowner(proxyowner(), newowner);
    }

    
    function claimproxyownership() external onlypendingproxyowner {
        emit proxyownershiptransferred(proxyowner(), pendingproxyowner());
        _setupgradeabilityowner(pendingproxyowner());
        _setpendingupgradeabilityowner(address(0));
    }

    
    function upgradeto(address implementation) external onlyproxyowner {
        _upgradeto(implementation);
    }
}