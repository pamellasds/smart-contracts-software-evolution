pragma solidity ^0.4.10;

contract owned {
    address public owner;

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
        address prevowner = owner;
        owner = _newowner;
        ownerupdate(prevowner, owner);
    }
}
