pragma solidity 0.4.25;

import ;
import ;



contract delegateapprovals is owned {
    bytes32 public constant burn_for_address = ;
    bytes32 public constant issue_for_address = ;
    bytes32 public constant claim_for_address = ;
    bytes32 public constant exchange_for_address = ;
    bytes32 public constant approve_all = ;

    bytes32[5] private _delegatablefunctions = [
        approve_all,
        burn_for_address,
        issue_for_address,
        claim_for_address,
        exchange_for_address
    ];

    
    eternalstorage public eternalstorage;

    
    constructor(address _owner, eternalstorage _eternalstorage) public owned(_owner) {
        eternalstorage = _eternalstorage;
    }

    

    

    
    function _getkey(bytes32 _action, address _authoriser, address _delegate) internal pure returns (bytes32) {
        return keccak256(abi.encodepacked(_action, _authoriser, _delegate));
    }

    
    function canburnfor(address authoriser, address delegate) external view returns (bool) {
        return _checkapproval(burn_for_address, authoriser, delegate);
    }

    function canissuefor(address authoriser, address delegate) external view returns (bool) {
        return _checkapproval(issue_for_address, authoriser, delegate);
    }

    function canclaimfor(address authoriser, address delegate) external view returns (bool) {
        return _checkapproval(claim_for_address, authoriser, delegate);
    }

    function canexchangefor(address authoriser, address delegate) external view returns (bool) {
        return _checkapproval(exchange_for_address, authoriser, delegate);
    }

    function approvedall(address authoriser, address delegate) public view returns (bool) {
        return eternalstorage.getbooleanvalue(_getkey(approve_all, authoriser, delegate));
    }

    
    
    
    function _checkapproval(bytes32 action, address authoriser, address delegate) internal view returns (bool) {
        if (approvedall(authoriser, delegate)) return true;

        return eternalstorage.getbooleanvalue(_getkey(action, authoriser, delegate));
    }

    

    
    function approvealldelegatepowers(address delegate) external {
        _setapproval(approve_all, msg.sender, delegate);
    }

    
    function removealldelegatepowers(address delegate) external {
        for (uint i = 0; i < _delegatablefunctions.length; i++) {
            _withdrawapproval(_delegatablefunctions[i], msg.sender, delegate);
        }
    }

    
    function approveburnonbehalf(address delegate) external {
        _setapproval(burn_for_address, msg.sender, delegate);
    }

    function removeburnonbehalf(address delegate) external {
        _withdrawapproval(burn_for_address, msg.sender, delegate);
    }

    
    function approveissueonbehalf(address delegate) external {
        _setapproval(issue_for_address, msg.sender, delegate);
    }

    function removeissueonbehalf(address delegate) external {
        _withdrawapproval(issue_for_address, msg.sender, delegate);
    }

    
    function approveclaimonbehalf(address delegate) external {
        _setapproval(claim_for_address, msg.sender, delegate);
    }

    function removeclaimonbehalf(address delegate) external {
        _withdrawapproval(claim_for_address, msg.sender, delegate);
    }

    
    function approveexchangeonbehalf(address delegate) external {
        _setapproval(exchange_for_address, msg.sender, delegate);
    }

    function removeexchangeonbehalf(address delegate) external {
        _withdrawapproval(exchange_for_address, msg.sender, delegate);
    }

    function _setapproval(bytes32 action, address authoriser, address delegate) internal {
        require(delegate != address(0), );
        eternalstorage.setbooleanvalue(_getkey(action, authoriser, delegate), true);
        emit approval(authoriser, delegate, action);
    }

    function _withdrawapproval(bytes32 action, address authoriser, address delegate) internal {
        
        if (eternalstorage.getbooleanvalue(_getkey(action, authoriser, delegate))) {
            eternalstorage.deletebooleanvalue(_getkey(action, authoriser, delegate));
            emit withdrawapproval(authoriser, delegate, action);
        }
    }

    function seteternalstorage(eternalstorage _eternalstorage) external onlyowner {
        require(_eternalstorage != address(0), );
        eternalstorage = _eternalstorage;
        emit eternalstorageupdated(eternalstorage);
    }

    
    event approval(address indexed authoriser, address delegate, bytes32 action);
    event withdrawapproval(address indexed authoriser, address delegate, bytes32 action);
    event eternalstorageupdated(address neweternalstorage);
}
