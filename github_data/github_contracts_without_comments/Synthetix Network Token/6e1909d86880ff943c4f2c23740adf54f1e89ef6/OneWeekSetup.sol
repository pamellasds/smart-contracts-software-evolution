pragma solidity 0.4.25;

import ;


contract oneweeksetup is limitedsetup(1 weeks) {
    function testfunc() public view onlyduringsetup returns (bool) {
        return true;
    }

    function publicsetupexpirytime() public view returns (uint) {
        return setupexpirytime;
    }
}
