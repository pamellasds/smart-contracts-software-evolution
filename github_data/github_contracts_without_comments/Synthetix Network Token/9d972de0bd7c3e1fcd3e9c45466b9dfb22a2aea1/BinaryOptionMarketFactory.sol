pragma solidity ^0.5.16;


import ;
import ;
import ;


import ;


contract binaryoptionmarketfactory is owned, selfdestructible, mixinresolver {
    

    

    bytes32 internal constant contract_binaryoptionmarketmanager = ;

    bytes32[24] internal addressestocache = [contract_binaryoptionmarketmanager];

    

    constructor(address _owner, address _resolver)
        public
        owned(_owner)
        selfdestructible()
        mixinresolver(_resolver, addressestocache)
    {}

    

    

    function _manager() internal view returns (address) {
        return requireandgetaddress(contract_binaryoptionmarketmanager, );
    }

    

    function createmarket(
        address creator,
        uint[2] calldata creatorlimits,
        bytes32 oraclekey,
        uint strikeprice,
        bool refundsenabled,
        uint[3] calldata times, 
        uint[2] calldata bids, 
        uint[3] calldata fees 
    ) external returns (binaryoptionmarket) {
        address manager = _manager();
        require(address(manager) == msg.sender, );

        return
            new binaryoptionmarket(
                manager,
                creator,
                creatorlimits,
                oraclekey,
                strikeprice,
                refundsenabled,
                times,
                bids,
                fees
            );
    }
}
