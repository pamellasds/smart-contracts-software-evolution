pragma solidity 0.4.25;

import ;


contract addressresolver is owned {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public owned(_owner) {}

    function getaddress(bytes32 name) public view returns (address) {
        return repository[name];
    }

    function importaddresses(bytes32[] names, address[] destinations) public onlyowner {
        require(names.length == destinations.length, );

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }
}
