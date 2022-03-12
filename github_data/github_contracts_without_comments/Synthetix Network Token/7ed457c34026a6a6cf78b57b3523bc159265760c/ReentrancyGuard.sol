


pragma solidity ^0.4.24;



contract reentrancyguard {
    
    uint256 private _guardcounter;

    constructor() internal {
        
        
        _guardcounter = 1;
    }

    
    modifier nonreentrant() {
        _guardcounter += 1;
        uint256 localcounter = _guardcounter;
        _;
        require(localcounter == _guardcounter);
    }
}
