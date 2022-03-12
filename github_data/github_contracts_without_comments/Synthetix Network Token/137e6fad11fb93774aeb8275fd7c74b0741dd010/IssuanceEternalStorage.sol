pragma solidity 0.4.25;

import ;



contract issuanceeternalstorage is eternalstorage {
    
    constructor(address _owner, address _issuer) public eternalstorage(_owner, _issuer) {}
}
