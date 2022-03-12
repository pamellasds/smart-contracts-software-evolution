

pragma solidity ^0.4.20;


contract owned {
    address public owner;
    address nominatedowner;

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
        newownernominated(_owner);
    }

    function _setowner()
        internal
    {
        ownerchanged(owner, nominatedowner);
        owner = nominatedowner;
        nominatedowner = address(0);
    }

    function acceptownership()
        external
    {
        require(msg.sender == nominatedowner);
        _setowner();
    }

    modifier onlyowner
    {
        require(msg.sender == owner);
        _;
    }

    event newownernominated(address newowner);
    event ownerchanged(address oldowner, address newowner);
}
