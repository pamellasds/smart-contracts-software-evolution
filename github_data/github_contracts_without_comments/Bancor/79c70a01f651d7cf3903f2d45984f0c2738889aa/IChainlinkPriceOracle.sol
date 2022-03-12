
pragma solidity 0.6.12;


interface ichainlinkpriceoracle {
    function latestanswer() external view returns (int256);
    function latesttimestamp() external view returns (uint256);
}
