

pragma solidity >=0.4.10;

contract owned {
    address public owner;
    address newowner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    function changeowner(address _newowner) onlyowner {
        newowner = _newowner;
    }

    function acceptownership() {
        if (msg.sender == newowner) {
            owner = newowner;
        }
    }
}