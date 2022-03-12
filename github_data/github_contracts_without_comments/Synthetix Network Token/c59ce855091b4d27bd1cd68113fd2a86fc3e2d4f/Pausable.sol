

pragma solidity 0.4.25;


import ;



contract pausable is owned {
    
    uint public lastpausetime;
    bool public paused;

    
    constructor(address _owner)
        owned(_owner)
        public
    {
        
    }

    
    function setpaused(bool _paused)
        external
        onlyowner
    {
        
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
