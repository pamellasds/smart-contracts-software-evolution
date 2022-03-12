
pragma solidity 0.6.12;
import ;


contract owned is iowned {
    address public override owner;
    address public newowner;

    
    event ownerupdate(address indexed _prevowner, address indexed _newowner);

    
    constructor() public {
        owner = msg.sender;
    }

    
    modifier owneronly {
        _owneronly();
        _;
    }

    
    function _owneronly() internal view {
        require(msg.sender == owner, );
    }

    
    function transferownership(address _newowner) public override owneronly {
        require(_newowner != owner, );
        newowner = _newowner;
    }

    
    function acceptownership() override public {
        require(msg.sender == newowner, );
        emit ownerupdate(owner, newowner);
        owner = newowner;
        newowner = address(0);
    }
}
