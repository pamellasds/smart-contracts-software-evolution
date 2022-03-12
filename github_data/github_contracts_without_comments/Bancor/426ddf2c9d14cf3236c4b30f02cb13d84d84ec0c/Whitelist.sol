pragma solidity ^0.4.23;
import ;
import ;
import ;


contract whitelist is iwhitelist, owned, utils {
    mapping (address => bool) private whitelist;

    event addressaddition(address _address);
    event addressremoval(address _address);

    
    constructor() public {
    }

    
    modifier whitelistedonly() {
        require(whitelist[msg.sender]);
        _;
    }

    
    function iswhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }

    
    function addaddress(address _address)
        owneronly
        validaddress(_address)
        public 
    {
        if (whitelist[_address]) 
            return;

        whitelist[_address] = true;
        emit addressaddition(_address);
    }

    
    function addaddresses(address[] _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addaddress(_addresses[i]);
        }
    }

    
    function removeaddress(address _address) owneronly public {
        if (!whitelist[_address]) 
            return;

        whitelist[_address] = false;
        emit addressremoval(_address);
    }

    
    function removeaddresses(address[] _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeaddress(_addresses[i]);
        }
    }
}
