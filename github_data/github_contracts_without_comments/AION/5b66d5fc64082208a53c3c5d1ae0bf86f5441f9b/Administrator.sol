
pragma solidity ^0.4.15;

import {owned} from ;


contract administrator is owned {
    
    mapping(address => bool) public admins;

    
    modifier onlyadministrator(address _address) {
        require(_address == owner || admins[_address]);
        _;
    }

    function addadmin(address _address)
        onlyowner
        external
    {
        require(_address != owner && !(admins[_address]));
        admins[_address] = true;
    }

    function deladmin(address _address)
        onlyowner
        external
    {
        require(_address != owner && admins[_address]);
        admins[_address] = false;
    }
}