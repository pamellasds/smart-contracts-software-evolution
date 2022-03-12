pragma solidity ^0.5.16;



contract limitedsetup {
    uint public setupexpirytime;

    
    constructor(uint setupduration) internal {
        setupexpirytime = now + setupduration;
    }

    modifier onlyduringsetup {
        require(now < setupexpirytime, );
        _;
    }
}
