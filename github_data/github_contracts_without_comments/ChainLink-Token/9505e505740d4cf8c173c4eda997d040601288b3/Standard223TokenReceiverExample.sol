pragma solidity ^0.4.11;

import ;

contract standard223tokenreceiverexample is standard223receiver {
    function tokenfallback(address from, uint value, bytes data){
        logfallbackparameters(from, value, data);
    }
    event logfallbackparameters(address from, uint value, bytes data);
}
