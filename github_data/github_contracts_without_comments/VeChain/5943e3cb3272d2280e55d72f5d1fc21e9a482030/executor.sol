pragma solidity ^0.4.23;








interface executor {    
    
    
    
    function propose(address _target, bytes _data) external returns(bytes32);

    
    
    function approve(bytes32 _proposalid) external;

    
    
    
    function execute(bytes32 _proposalid) external;

    
    
    
    function addapprover(address _approver, bytes32 _identity) external;

    
    function revokeapprover(address _approver) external;

    
    function attachvotingcontract(address _contract) external;

    
    function detachvotingcontract(address _contract) external;
}