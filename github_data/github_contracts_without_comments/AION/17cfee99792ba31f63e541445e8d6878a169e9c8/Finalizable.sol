

pragma solidity >=0.4.10;

import ;

contract finalizable is owned {
    bool public finalized;

    function finalize() onlyowner {
        finalized = true;
    }

    modifier notfinalized() {
        require(!finalized);
        _;
    }
}