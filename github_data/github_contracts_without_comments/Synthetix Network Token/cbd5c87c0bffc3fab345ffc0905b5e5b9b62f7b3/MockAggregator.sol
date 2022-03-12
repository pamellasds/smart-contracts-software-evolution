pragma solidity ^0.5.16;


interface aggregatorinterface {
    function latestanswer() external view returns (int256);

    function latesttimestamp() external view returns (uint256);

    function latestround() external view returns (uint256);

    function getanswer(uint256 roundid) external view returns (int256);

    function gettimestamp(uint256 roundid) external view returns (uint256);

    
    
}


contract mockaggregator is aggregatorinterface {
    uint public roundid = 0;

    struct entry {
        int256 answer;
        uint256 timestamp;
    }

    mapping(uint => entry) public entries;

    constructor() public {}

    
    function setlatestanswer(int256 answer, uint256 timestamp) external {
        roundid++;
        entries[roundid] = entry({answer: answer, timestamp: timestamp});
    }

    function latestanswer() external view returns (int256) {
        return getanswer(latestround());
    }

    function latesttimestamp() external view returns (uint256) {
        return gettimestamp(latestround());
    }

    function latestround() public view returns (uint256) {
        return roundid;
    }

    function getanswer(uint256 _roundid) public view returns (int256) {
        return entries[_roundid].answer;
    }

    function gettimestamp(uint256 _roundid) public view returns (uint256) {
        return entries[_roundid].timestamp;
    }
}
