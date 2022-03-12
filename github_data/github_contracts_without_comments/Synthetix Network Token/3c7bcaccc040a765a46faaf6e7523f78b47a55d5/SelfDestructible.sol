pragma solidity ^0.5.16;

import ;



contract selfdestructible is owned {
    uint public constant selfdestruct_delay = 4 weeks;

    uint public initiationtime;
    bool public selfdestructinitiated;

    address public selfdestructbeneficiary;

    constructor() internal {
        
        require(owner != address(0), );
        selfdestructbeneficiary = owner;
        emit selfdestructbeneficiaryupdated(owner);
    }

    
    function setselfdestructbeneficiary(address payable _beneficiary) external onlyowner {
        require(_beneficiary != address(0), );
        selfdestructbeneficiary = _beneficiary;
        emit selfdestructbeneficiaryupdated(_beneficiary);
    }

    
    function initiateselfdestruct() external onlyowner {
        initiationtime = now;
        selfdestructinitiated = true;
        emit selfdestructinitiated(selfdestruct_delay);
    }

    
    function terminateselfdestruct() external onlyowner {
        initiationtime = 0;
        selfdestructinitiated = false;
        emit selfdestructterminated();
    }

    
    function selfdestruct() external onlyowner {
        require(selfdestructinitiated, );
        require(initiationtime + selfdestruct_delay < now, );
        emit selfdestructed(selfdestructbeneficiary);
        selfdestruct(address(uint160(selfdestructbeneficiary)));
    }

    event selfdestructterminated();
    event selfdestructed(address beneficiary);
    event selfdestructinitiated(uint selfdestructdelay);
    event selfdestructbeneficiaryupdated(address newbeneficiary);
}
