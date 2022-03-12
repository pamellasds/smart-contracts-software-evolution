pragma solidity ^0.4.11;
import ;


contract owned is iowned {
    address public owner;
    address public newowner;

    event ownerupdate(address _prevowner, address _newowner);

    
    function owned() {
        owner = msg.sender;
    }

    
    modifier owneronly {
        assert(msg.sender == owner);
        _;
    }

    
    function setowner(address _newowner) public owneronly {
        require(_newowner != owner);
        newowner = _newowner;
    }

    
    function acceptownership() public {
        require(msg.sender == newowner);
        address prevowner = owner;
        owner = newowner;
        newowner = 0x0;
        ownerupdate(prevowner, owner);
    }
}
