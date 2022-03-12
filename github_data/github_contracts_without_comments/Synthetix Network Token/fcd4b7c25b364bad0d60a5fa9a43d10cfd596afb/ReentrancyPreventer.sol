

pragma solidity 0.4.25;

contract reentrancypreventer {
    
    bool isinfunctionbody = false;

    modifier preventreentrancy {
        require(!isinfunctionbody, );
        isinfunctionbody = true;
        _;
        isinfunctionbody = false;
    }
}