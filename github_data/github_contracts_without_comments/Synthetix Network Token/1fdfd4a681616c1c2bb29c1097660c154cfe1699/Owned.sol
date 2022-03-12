

pragma solidity ^0.4.19;

contract owned {
    address public owner;

    function owned(address _owner)
        public
    {
        owner = _owner;
    }

    function setowner(address newowner)
        public
        onlyowner
    {
        owner = newowner;
        ownerchanged(owner, newowner);
    }

    modifier onlyowner
    {
        require(msg.sender == owner);
        _;
    }

    event ownerchanged(address oldowner, address newowner);
}
