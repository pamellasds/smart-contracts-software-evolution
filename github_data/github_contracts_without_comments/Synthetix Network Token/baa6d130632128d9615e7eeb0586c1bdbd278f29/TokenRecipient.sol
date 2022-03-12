pragma solidity ^0.4.24;

contract tokenrecipient {
    event tokenfallbackcalled(address from, uint value, bytes data);

    function tokenfallback(address from, uint value, bytes data) public {
        emit tokenfallbackcalled(from, value, data);
    }
}