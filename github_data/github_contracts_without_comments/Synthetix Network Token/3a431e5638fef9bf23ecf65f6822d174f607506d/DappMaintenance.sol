pragma solidity 0.4.25;

import ;


contract dappmaintenance is owned {
    bool public ispausedmintr = false;
    bool public ispausedsx = false;

    constructor(address _owner) public owned(_owner) {}

    function setmaintenancemodeall(bool ispaused) external onlyowner {
        ispausedmintr = ispaused;
        ispausedsx = ispaused;
        emit mintrmaintenance(ispaused);
        emit sxmaintenance(ispaused);
    }

    function setmaintenancemodemintr(bool ispaused) external onlyowner {
        ispausedmintr = ispaused;
        emit mintrmaintenance(ispausedmintr);
    }

    function setmaintenancemodesx(bool ispaused) external onlyowner {
        ispausedsx = ispaused;
        emit sxmaintenance(ispausedsx);
    }

    event mintrmaintenance(bool ispaused);
    event sxmaintenance(bool ispaused);
}
