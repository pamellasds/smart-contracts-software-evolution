pragma solidity 0.4.25;

import ;


contract addressresolver is owned {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public owned(_owner) {}

    

    function importaddresses(bytes32[] names, address[] destinations) public onlyowner {
        require(names.length == destinations.length, );

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }

    

    function getaddress(bytes32 name) public view returns (address) {
        return repository[name];
    }

    function requireandgetaddress(bytes32 name, string reason) public view returns (address) {
        address _foundaddress = repository[name];
        require(_foundaddress != address(0), reason);
        return _foundaddress;
    }
}
