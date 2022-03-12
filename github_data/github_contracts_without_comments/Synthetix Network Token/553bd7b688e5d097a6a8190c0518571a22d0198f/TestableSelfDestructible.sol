pragma solidity ^0.5.16;

import ;
import ;


contract testableselfdestructible is owned, selfdestructible {
    constructor(address _owner) public owned(_owner) selfdestructible() {}
}
