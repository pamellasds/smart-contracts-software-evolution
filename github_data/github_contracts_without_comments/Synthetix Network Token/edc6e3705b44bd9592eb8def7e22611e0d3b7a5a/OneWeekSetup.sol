pragma solidity ^0.5.16;

import ;


contract oneweeksetup is limitedsetup(1 weeks) {
    function testfunc() public view onlyduringsetup returns (bool) {
        return true;
    }

    function publicsetupexpirytime() public view returns (uint) {
        return setupexpirytime;
    }
}
