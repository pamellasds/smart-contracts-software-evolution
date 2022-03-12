
pragma solidity 0.6.12;

import ;


contract chainlinkethtoethoracle is ichainlinkpriceoracle {
    int256 private constant eth_rate = 1;

    
    function latestanswer() external override view returns (int256) {
        return eth_rate;
    }

    
    function latesttimestamp() external override view returns (uint256) {
        return now;
    }
}
