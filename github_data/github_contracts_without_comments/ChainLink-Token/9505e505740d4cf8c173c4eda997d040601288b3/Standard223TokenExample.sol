pragma solidity ^0.4.11;

import ;

contract standard223tokenexample is standard223token {

    function standard223tokenexample(uint _initialbalance) {
        balances[msg.sender] = _initialbalance;
        totalsupply = _initialbalance;
    }
}
