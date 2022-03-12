pragma solidity ^0.4.23;
import ;


contract owned is iowned {
    address public owner;
    address public newowner;

    event ownerupdate(address indexed _prevowner, address indexed _newowner);

    
    constructor() public {
        owner = msg.sender;
    }

    
    modifier owneronly {
        require(msg.sender == owner);
        _;
    }

    
    function transferownership(address _newowner) public owneronly {
        require(_newowner != owner);
        newowner = _newowner;
    }

    
    function acceptownership() public {
        require(msg.sender == newowner);
        emit ownerupdate(owner, newowner);
        owner = newowner;
        newowner = address(0);
    }
}
