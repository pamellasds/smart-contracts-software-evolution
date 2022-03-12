pragma solidity 0.4.25;

import ;



contract delegateapprovals is state {
    
    
    mapping(address => mapping(address => bool)) public approval;

    
    constructor(address _owner, address _associatedcontract) public state(_owner, _associatedcontract) {}

    function setapproval(address authoriser, address delegate) external onlyassociatedcontract {
        approval[authoriser][delegate] = true;
        emit approval(authoriser, delegate);
    }

    function withdrawapproval(address authoriser, address delegate) external onlyassociatedcontract {
        delete approval[authoriser][delegate];
        emit withdrawapproval(authoriser, delegate);
    }

    

    event approval(address indexed authoriser, address delegate);
    event withdrawapproval(address indexed authoriser, address delegate);
}
