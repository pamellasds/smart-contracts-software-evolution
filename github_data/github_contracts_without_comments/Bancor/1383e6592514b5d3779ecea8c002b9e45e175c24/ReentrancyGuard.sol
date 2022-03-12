
pragma solidity 0.6.12;


contract reentrancyguard {
    
    bool private locked = false;

    
    constructor() internal {}

    
    modifier protected() {
        _protected();
        locked = true;
        _;
        locked = false;
    }

    
    function _protected() internal view {
        require(!locked, );
    }
}
