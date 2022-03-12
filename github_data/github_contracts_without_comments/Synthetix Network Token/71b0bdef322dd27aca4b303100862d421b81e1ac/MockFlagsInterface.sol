pragma solidity ^0.5.16;


interface flagsinterface {
    function getflag(address) external view returns (bool);

    function getflags(address[] calldata) external view returns (bool[] memory);
}


contract mockflagsinterface is flagsinterface {
    mapping(address => bool) public flags;

    constructor() public {}

    function getflag(address aggregator) external view returns (bool) {
        return flags[aggregator];
    }

    function getflags(address[] calldata aggregators) external view returns (bool[] memory results) {
        results = new bool[](aggregators.length);

        for (uint i = 0; i < aggregators.length; i++) {
            results[i] = flags[aggregators[i]];
        }
    }

    function flagaggregator(address aggregator) external returns (bool) {
        flags[aggregator] = true;
    }
}
