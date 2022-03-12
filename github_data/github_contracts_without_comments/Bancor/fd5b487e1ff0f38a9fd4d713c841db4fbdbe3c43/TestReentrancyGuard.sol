
pragma solidity 0.6.12;
import ;


contract testreentrancyguardattacker {
    testreentrancyguard public target;
    bool public reentrancy;
    bool public callprotectedmethod;
    bool public attacking;

    constructor(testreentrancyguard _target) public {
        target = _target;
    }

    function setreentrancy(bool _reentrancy) external {
        reentrancy = _reentrancy;
    }

    function setcallprotectedmethod(bool _callprotectedmethod) external {
        callprotectedmethod = _callprotectedmethod;
    }

    function run() public {
        callprotectedmethod ? target.protectedmethod() : target.unprotectedmethod();
    }

    function callback() external {
        if (!reentrancy) {
            return;
        }

        if (!attacking) {
            attacking = true;

            run();
        }

        attacking = false;
    }
}

contract testreentrancyguard is reentrancyguard {
    uint256 public calls;

    function protectedmethod() external protected {
        run();
    }

    function unprotectedmethod() external {
        run();
    }

    function run() private {
        calls++;

        testreentrancyguardattacker(msg.sender).callback();
    }
}
