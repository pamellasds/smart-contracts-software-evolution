pragma solidity ^0.5.16;

import ;
import ;


contract mockbinaryoptionmarketmanager {
    binaryoptionmarket public market;
    bool public paused = false;

    function createmarket(
        addressresolver resolver,
        address creator,
        uint[2] calldata creatorlimits,
        bytes32 oraclekey,
        uint strikeprice,
        bool refundsenabled,
        uint[3] calldata times, 
        uint[2] calldata bids, 
        uint[3] calldata fees 
    ) external {
        market = new binaryoptionmarket(
            address(this),
            creator,
            creatorlimits,
            oraclekey,
            strikeprice,
            refundsenabled,
            times,
            bids,
            fees
        );
        market.setresolverandsynccache(resolver);
    }

    function decrementtotaldeposited(uint) external pure {
        return;
    }

    function resolvemarket() external {
        market.resolve();
    }

    function durations()
        external
        pure
        returns (
            uint,
            uint,
            uint
        )
    {
        return (60 * 60 * 24, 0, 0);
    }
}
