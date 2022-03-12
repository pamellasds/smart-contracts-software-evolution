pragma solidity ^0.4.9;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyowner {
        if (msg.sender != owner)
            throw;
        _;
    }
}
