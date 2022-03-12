pragma solidity ^0.4.24;
import ;


contract managed is owned {
    address public manager;
    address public newmanager;

    
    event managerupdate(address indexed _prevmanager, address indexed _newmanager);

    
    constructor() public {
        manager = msg.sender;
    }

    
    modifier manageronly {
        assert(msg.sender == manager);
        _;
    }

    
    modifier ownerormanageronly {
        require(msg.sender == owner || msg.sender == manager);
        _;
    }

    
    function transfermanagement(address _newmanager) public ownerormanageronly {
        require(_newmanager != manager);
        newmanager = _newmanager;
    }

    
    function acceptmanagement() public {
        require(msg.sender == newmanager);
        emit managerupdate(manager, newmanager);
        manager = newmanager;
        newmanager = address(0);
    }
}
