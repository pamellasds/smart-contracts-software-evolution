

contract reentrancypreventer {
    
    bool isinfunctionbody = false;

    modifier preventreentrancy {
        require(!isinfunctionbody, );
        isinfunctionbody = true;
        _;
        isinfunctionbody = false;
    }
}