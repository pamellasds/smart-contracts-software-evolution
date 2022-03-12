pragma solidity 0.4.24;

import ;

contract busdwithbalance is busdimplementation {

    function initializebalance(address initialaccount, uint initialbalance) public {
        balances[initialaccount] = initialbalance;
        totalsupply_ = initialbalance;
    }

}
