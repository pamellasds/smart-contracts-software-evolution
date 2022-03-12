

pragma solidity >=0.4.10;

import ;

contract pausable is owned {
    bool public paused;

    function pause() onlyowner {
        paused = true;
    }

    function unpause() onlyowner {
        paused = false;
    }

    modifier notpaused() {
        require(!paused);
        _;
    }
}