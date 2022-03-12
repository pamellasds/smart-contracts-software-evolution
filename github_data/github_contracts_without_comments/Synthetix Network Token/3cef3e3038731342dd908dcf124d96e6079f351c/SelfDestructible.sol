pragma solidity 0.4.25;

import ;



contract selfdestructible is owned {
    uint public initiationtime;
    bool public selfdestructinitiated;
    address public selfdestructbeneficiary;
    uint public constant selfdestruct_delay = 4 weeks;

    
    constructor(address _owner) public owned(_owner) {
        require(_owner != address(0), );
        selfdestructbeneficiary = _owner;
        emit selfdestructbeneficiaryupdated(_owner);
    }

    
    function setselfdestructbeneficiary(address _beneficiary) external onlyowner {
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
        address beneficiary = selfdestructbeneficiary;
        emit selfdestructed(beneficiary);
        selfdestruct(beneficiary);
    }

    event selfdestructterminated();
    event selfdestructed(address beneficiary);
    event selfdestructinitiated(uint selfdestructdelay);
    event selfdestructbeneficiaryupdated(address newbeneficiary);
}
