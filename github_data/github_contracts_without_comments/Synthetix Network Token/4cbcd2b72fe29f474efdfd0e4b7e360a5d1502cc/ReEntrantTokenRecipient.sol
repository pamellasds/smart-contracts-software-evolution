pragma solidity ^0.4.24;

import ;

contract reentranttokenrecipient {
    event tokenfallbackcalled(address from, uint value, bytes data);

    function tokenfallback(address from, uint value, bytes data) public {
        emit tokenfallbackcalled(from, value, data);

        publicest(msg.sender).transferfrom(from, this, value);
    }
}