


pragma solidity 0.4.24;


import ;


contract state is owned {
    
    
    address public associatedcontract;


    constructor(address _owner, address _associatedcontract)
        owned(_owner)
        public
    {
        associatedcontract = _associatedcontract;
        emit associatedcontractupdated(_associatedcontract);
    }

    

    
    function setassociatedcontract(address _associatedcontract)
        external
        onlyowner
    {
        associatedcontract = _associatedcontract;
        emit associatedcontractupdated(_associatedcontract);
    }

    

    modifier onlyassociatedcontract
    {
        require(msg.sender == associatedcontract);
        _;
    }

    

    event associatedcontractupdated(address associatedcontract);
}
