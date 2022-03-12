pragma solidity ^0.4.24;
import ;
import ;


contract nonstandardtokenregistry is iaddresslist, owned {

    mapping (address => bool) public listedaddresses;

    
    constructor() public {

    }

    function setaddress(address token, bool register) public owneronly {
        listedaddresses[token] = register;
    }
}