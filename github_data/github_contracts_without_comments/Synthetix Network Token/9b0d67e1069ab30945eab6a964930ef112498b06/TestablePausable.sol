pragma solidity ^0.5.16;

import ;
import ;



contract testablepausable is owned, pausable {
    uint public somevalue;

    constructor(address _owner) public owned(_owner) pausable() {}

    function setsomevalue(uint _value) external notpaused {
        somevalue = _value;
    }
}
