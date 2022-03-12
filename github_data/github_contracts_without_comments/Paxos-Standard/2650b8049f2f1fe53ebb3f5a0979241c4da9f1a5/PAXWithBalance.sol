pragma solidity ^0.4.24;

import ;


contract paxwithbalance is paximplementationv2 {

    function initializebalance(address initialaccount, uint initialbalance) public {
        balances[initialaccount] = initialbalance;
        totalsupply_ = initialbalance;
    }

}
