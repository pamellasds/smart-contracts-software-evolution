


pragma solidity 0.4.21;


contract limitedsetup {

    uint setupexpirytime;

    
    function limitedsetup(uint setupduration)
        public
    {
        setupexpirytime = now + setupduration;
    }

    modifier setupfunction
    {
        require(now < setupexpirytime);
        _;
    }
}
