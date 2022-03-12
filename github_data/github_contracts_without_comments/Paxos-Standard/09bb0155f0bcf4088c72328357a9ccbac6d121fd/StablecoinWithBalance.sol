pragma solidity ^0.4.24;

import ;


contract stablecoinwithbalance is stablecoinimplementation {

    function initializebalance(address initialaccount, uint initialbalance) public {
        balances[initialaccount] = initialbalance;
        totalsupply_ = initialbalance;
    }

}
