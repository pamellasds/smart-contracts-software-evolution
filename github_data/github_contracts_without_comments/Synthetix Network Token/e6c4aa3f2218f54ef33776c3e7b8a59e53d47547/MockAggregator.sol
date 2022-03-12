pragma solidity 0.4.25;


interface aggregatorinterface {
    function latestanswer() external view returns (int256);

    function latesttimestamp() external view returns (uint256);
    
    
    

    
    
}


contract mockaggregator is aggregatorinterface {
    int256 private _latestanswer;
    uint256 private _latesttimestamp;

    constructor() public {}

    
    function setlatestanswer(int256 answer, uint256 timestamp) external {
        _latestanswer = answer;
        _latesttimestamp = timestamp;
    }

    function latestanswer() external view returns (int256) {
        return _latestanswer;
    }

    function latesttimestamp() external view returns (uint256) {
        return _latesttimestamp;
    }
}
