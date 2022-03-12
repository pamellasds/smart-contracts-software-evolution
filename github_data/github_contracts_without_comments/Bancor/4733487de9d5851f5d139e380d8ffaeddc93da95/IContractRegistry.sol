pragma solidity ^0.4.24;


contract icontractregistry {
    function addressof(bytes32 _contractname) public view returns (address);

    
    function getaddress(bytes32 _contractname) public view returns (address);
}
