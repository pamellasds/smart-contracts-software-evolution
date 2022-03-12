pragma solidity ^0.4.8;

contract owned {
    address public owner;

    event newowner(address indexed _prevowner, address indexed _newowner);

    function owned() {
        owner = msg.sender;
    }

    
    modifier owneronly {
        if (msg.sender != owner)
            throw;
        _;
    }

    
    function setowner(address _newowner) public owneronly {
        if (owner == _newowner)
            throw;

        address prevowner = owner;
        owner = _newowner;
        newowner(prevowner, owner);
    }
}
