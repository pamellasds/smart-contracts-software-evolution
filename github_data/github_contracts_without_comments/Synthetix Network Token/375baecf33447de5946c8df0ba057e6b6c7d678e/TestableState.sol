pragma solidity ^0.5.16;

import ;
import ;


contract testablestate is owned, state {
    constructor(address _owner, address _associatedcontract) public owned(_owner) state(_associatedcontract) {}

    function testmodifier() external onlyassociatedcontract {}
}
