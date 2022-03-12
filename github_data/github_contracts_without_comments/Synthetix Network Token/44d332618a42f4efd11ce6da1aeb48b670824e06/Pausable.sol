pragma solidity ^0.5.16;

import ;



contract pausable is owned {
    uint public lastpausetime;
    bool public paused;

    constructor() public {
        
        require(owner != address(0), );
        
    }

    
    function setpaused(bool _paused) external onlyowner {
        
        if (_paused == paused) {
            return;
        }

        
        paused = _paused;

        
        if (paused) {
            lastpausetime = now;
        }

        
        emit pausechanged(paused);
    }

    event pausechanged(bool ispaused);

    modifier notpaused {
        require(!paused, );
        _;
    }
}
