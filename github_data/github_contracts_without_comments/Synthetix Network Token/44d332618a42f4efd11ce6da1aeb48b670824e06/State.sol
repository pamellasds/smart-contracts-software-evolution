pragma solidity ^0.5.16;

import ;



contract state is owned {
    
    
    address public associatedcontract;

    constructor(address _associatedcontract) public {
        
        require(owner != address(0), );

        associatedcontract = _associatedcontract;
        emit associatedcontractupdated(_associatedcontract);
    }

    

    
    function setassociatedcontract(address _associatedcontract) external onlyowner {
        associatedcontract = _associatedcontract;
        emit associatedcontractupdated(_associatedcontract);
    }

    

    modifier onlyassociatedcontract {
        require(msg.sender == associatedcontract, );
        _;
    }

    

    event associatedcontractupdated(address associatedcontract);
}
