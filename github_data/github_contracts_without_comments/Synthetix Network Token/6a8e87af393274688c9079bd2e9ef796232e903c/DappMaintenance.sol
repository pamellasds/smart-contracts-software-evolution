pragma solidity ^0.5.16;

import ;



contract dappmaintenance is owned {
    bool public ispausedstaking = false;
    bool public ispausedsx = false;

    
    constructor(address _owner) public owned(_owner) {
        require(_owner != address(0), );
        owner = _owner;
        emit ownerchanged(address(0), _owner);
    }

    function setmaintenancemodeall(bool ispaused) external onlyowner {
        ispausedstaking = ispaused;
        ispausedsx = ispaused;
        emit stakingmaintenance(ispaused);
        emit sxmaintenance(ispaused);
    }

    function setmaintenancemodestaking(bool ispaused) external onlyowner {
        ispausedstaking = ispaused;
        emit stakingmaintenance(ispausedstaking);
    }

    function setmaintenancemodesx(bool ispaused) external onlyowner {
        ispausedsx = ispaused;
        emit sxmaintenance(ispausedsx);
    }

    event stakingmaintenance(bool ispaused);
    event sxmaintenance(bool ispaused);
}
