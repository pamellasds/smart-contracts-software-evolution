pragma solidity ^0.4.24;

import ;


contract paxwithbalance is paximplementation {

    function initializebalance(address initialaccount, uint initialbalance) public {
        balances[initialaccount] = initialbalance;
        totalsupply_ = initialbalance;
    }

}
