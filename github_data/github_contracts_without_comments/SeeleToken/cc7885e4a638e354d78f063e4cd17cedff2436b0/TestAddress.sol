pragma solidity ^0.4.4;

import ;

contract testaddress is pausable {
    
    
    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }
    function testaddress (address _admin, uint val ) public validaddress(_admin) {
        transferownership(_admin);
    }
}