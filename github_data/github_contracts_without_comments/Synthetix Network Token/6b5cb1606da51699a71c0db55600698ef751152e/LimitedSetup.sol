


pragma solidity 0.4.24;


contract limitedsetup {

    uint setupexpirytime;

    
    constructor(uint setupduration)
        public
    {
        setupexpirytime = now + setupduration;
    }

    modifier onlyduringsetup
    {
        require(now < setupexpirytime, );
        _;
    }
}
