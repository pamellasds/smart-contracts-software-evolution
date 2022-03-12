pragma solidity ^0.5.16;


import ;



contract contractstorage {
    iaddressresolver public resolverproxy;

    mapping(bytes32 => bytes32) public hashes;

    constructor(address _resolver) internal {
        
        resolverproxy = iaddressresolver(_resolver);
    }

    

    function _memoizehash(bytes32 contractname) internal returns (bytes32) {
        bytes32 hashkey = hashes[contractname];
        if (hashkey == bytes32(0)) {
            
            hashkey = keccak256(abi.encodepacked(msg.sender, contractname, block.number));
            hashes[contractname] = hashkey;
        }
        return hashkey;
    }

    

    

    function migratecontractkey(
        bytes32 fromcontractname,
        bytes32 tocontractname,
        bool removeaccessfrompreviouscontract
    ) external onlycontract(fromcontractname) {
        require(hashes[fromcontractname] != bytes32(0), );

        hashes[tocontractname] = hashes[fromcontractname];

        if (removeaccessfrompreviouscontract) {
            delete hashes[fromcontractname];
        }

        emit keymigrated(fromcontractname, tocontractname, removeaccessfrompreviouscontract);
    }

    

    modifier onlycontract(bytes32 contractname) {
        address callingcontract = resolverproxy.requireandgetaddress(
            contractname,
            
        );
        require(callingcontract == msg.sender, );
        _;
    }

    

    event keymigrated(bytes32 fromcontractname, bytes32 tocontractname, bool removeaccessfrompreviouscontract);
}
