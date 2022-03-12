pragma solidity ^0.5.16;


import ;





contract issuanceeternalstorage is eternalstorage {
    constructor(address _owner, address _issuer) public eternalstorage(_owner, _issuer) {}
}
