pragma solidity ^0.4.11;


import ;


contract standard223tokenreceiverexample is standard223receiver {
    event logfallbackparameters(address from, uint value, bytes data);

    function tokenfallback(address from, uint value, bytes data)
    public returns (bool success)
    {
        logfallbackparameters(from, value, data);
    }
}
