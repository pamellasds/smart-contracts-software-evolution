pragma solidity 0.4.26;


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
