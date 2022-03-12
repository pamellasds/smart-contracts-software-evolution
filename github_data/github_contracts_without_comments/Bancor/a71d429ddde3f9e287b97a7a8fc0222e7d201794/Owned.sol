pragma solidity ^0.4.8;

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
