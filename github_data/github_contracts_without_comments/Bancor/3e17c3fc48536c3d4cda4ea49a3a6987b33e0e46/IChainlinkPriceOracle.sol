pragma solidity 0.4.26;


interface ichainlinkpriceoracle {
    function latestanswer() external view returns (int256);
    function latesttimestamp() external view returns (uint256);
}
