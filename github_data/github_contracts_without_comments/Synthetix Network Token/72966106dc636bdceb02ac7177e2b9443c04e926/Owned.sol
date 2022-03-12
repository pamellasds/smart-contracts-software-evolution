pragma solidity ^0.5.16;



contract owned {
    address public owner;
    address public nominatedowner;

    constructor(address _owner) public {
        require(_owner != address(0), );
        owner = _owner;
        emit ownerchanged(address(0), _owner);
    }

    function nominatenewowner(address _owner) external onlyowner {
        nominatedowner = _owner;
        emit ownernominated(_owner);
    }

    function acceptownership() external {
        require(msg.sender == nominatedowner, );
        emit ownerchanged(owner, nominatedowner);
        owner = nominatedowner;
        nominatedowner = address(0);
    }

    modifier onlyowner {
        _onlyowner();
        _;
    }

    function _onlyowner() private view {
        require(msg.sender == owner, );
    }

    event ownernominated(address newowner);
    event ownerchanged(address oldowner, address newowner);
}
