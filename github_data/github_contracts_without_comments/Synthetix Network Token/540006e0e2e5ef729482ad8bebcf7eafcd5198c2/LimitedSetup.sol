


pragma solidity ^0.4.20;


contract limitedsetup {

    uint constructiontime;
    uint setupduration;

    function limitedsetup(uint _setupduration)
        public
    {
        constructiontime = now;
        setupduration = _setupduration;
    }

    modifier setupfunction
    {
        require(now < constructiontime + setupduration);
        _;
    }
}
