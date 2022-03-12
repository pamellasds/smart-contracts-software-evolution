pragma solidity ^0.4.8;


import ;


contract standard223tokenreceivermock is standard223receiver {
    address public tokensender;
    uint public sentvalue;
    bytes public tokendata;
    bool public calledfallback = false;

    function tokenfallback(address from, uint value, bytes data)
    {
        calledfallback = true;

        tokensender = from;
        sentvalue = value;
        tokendata = data;
    }

}
