

pragma solidity ^0.4.21;


contract owned {
    address public owner;
    address public nominatedowner;

    
    function owned(address _owner)
        public
    {
        owner = _owner;
    }

    
    function nominateowner(address _owner)
        external
        onlyowner
    {
        nominatedowner = _owner;
        emit ownernominated(_owner);
    }

    
    function acceptownership()
        external
    {
        require(msg.sender == nominatedowner);
        emit ownerchanged(owner, nominatedowner);
        owner = nominatedowner;
        nominatedowner = address(0);
    }

    modifier onlyowner
    {
        require(msg.sender == owner);
        _;
    }

    event ownernominated(address newowner);
    event ownerchanged(address oldowner, address newowner);
}
