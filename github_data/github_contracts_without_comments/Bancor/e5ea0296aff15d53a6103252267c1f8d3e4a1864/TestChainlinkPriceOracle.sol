pragma solidity 0.4.26;
import ;


contract testchainlinkpriceoracle is ichainlinkpriceoracle {
    int256 private answer;
    uint256 private timestamp;

    function setanswer(int256 _answer) public {
        answer = _answer;
        settimestamp(now);
    }

    function settimestamp(uint256 _timestamp) public {
        timestamp = _timestamp;
    }

    function latestanswer() external view returns (int256) {
        return answer;
    }

    function latesttimestamp() external view returns (uint256) {
        return timestamp;
    }
}
