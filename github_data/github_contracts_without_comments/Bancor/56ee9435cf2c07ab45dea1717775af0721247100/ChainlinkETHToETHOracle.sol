pragma solidity 0.4.26;

import ;


contract chainlinkethtoethoracle is ichainlinkpriceoracle {
    int256 private constant eth_rate = 1;

    
    function latestanswer() external view returns (int256) {
        return eth_rate;
    }

    
    function latesttimestamp() external view returns (uint256) {
        return now;
    }
}
