pragma solidity ^0.5.16;

import ;


contract mockcontractstorage is contractstorage {
    struct someentry {
        uint value;
        bool flag;
    }

    mapping(bytes32 => mapping(bytes32 => someentry)) public entries;

    constructor(address _resolver) public contractstorage(_resolver) {}

    function getentry(bytes32 contractname, bytes32 record) external view returns (uint value, bool flag) {
        someentry storage entry = entries[hashes[contractname]][record];
        return (entry.value, entry.flag);
    }

    function persistentry(
        bytes32 contractname,
        bytes32 record,
        uint value,
        bool flag
    ) external onlycontract(contractname) {
        entries[_memoizehash(contractname)][record].value = value;
        entries[_memoizehash(contractname)][record].flag = flag;
    }
}
