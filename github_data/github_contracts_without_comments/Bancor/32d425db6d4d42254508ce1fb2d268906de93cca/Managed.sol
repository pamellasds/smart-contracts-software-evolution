pragma solidity ^0.4.11;


contract managed {
    address public manager;
    address public newmanager;

    event managerupdate(address _prevmanager, address _newmanager);

    
    function managed() {
        manager = msg.sender;
    }

    
    modifier manageronly {
        assert(msg.sender == manager);
        _;
    }

    
    function transfermanagement(address _newmanager) public manageronly {
        require(_newmanager != manager);
        newmanager = _newmanager;
    }

    
    function acceptmanagement() public {
        require(msg.sender == newmanager);
        managerupdate(manager, newmanager);
        manager = newmanager;
        newmanager = 0x0;
    }
}
