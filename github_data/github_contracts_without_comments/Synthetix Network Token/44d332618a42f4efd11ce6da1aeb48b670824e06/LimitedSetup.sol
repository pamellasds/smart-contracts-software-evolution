pragma solidity ^0.5.16;



contract limitedsetup {
    uint setupexpirytime;

    
    constructor(uint setupduration) public {
        setupexpirytime = now + setupduration;
    }

    modifier onlyduringsetup {
        require(now < setupexpirytime, );
        _;
    }
}
