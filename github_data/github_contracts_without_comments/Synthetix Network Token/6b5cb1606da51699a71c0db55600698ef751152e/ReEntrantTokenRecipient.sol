pragma solidity ^0.4.24;

import ;

contract reentranttokenrecipient {
    event tokenfallbackcalled(address from, uint value);

    function havventokenfallback(address from, uint value) public {
        emit tokenfallbackcalled(from, value);

        publicest(msg.sender).transferfrom(from, this, value);
    }
}