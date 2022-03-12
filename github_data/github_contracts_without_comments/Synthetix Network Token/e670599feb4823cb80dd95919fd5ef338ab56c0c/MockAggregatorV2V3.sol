pragma solidity ^0.5.16;


interface aggregatorv2v3interface {
    function latestround() external view returns (uint256);

    function decimals() external view returns (uint8);

    function getrounddata(uint80 _roundid)
        external
        view
        returns (
            uint80 roundid,
            int256 answer,
            uint256 startedat,
            uint256 updatedat,
            uint80 answeredinround
        );

    function latestrounddata()
        external
        view
        returns (
            uint80 roundid,
            int256 answer,
            uint256 startedat,
            uint256 updatedat,
            uint80 answeredinround
        );
}


contract mockaggregatorv2v3 is aggregatorv2v3interface {
    uint80 public roundid = 0;
    uint8 public keydecimals = 0;

    struct entry {
        uint80 roundid;
        int256 answer;
        uint256 startedat;
        uint256 updatedat;
        uint80 answeredinround;
    }

    mapping(uint => entry) public entries;

    constructor() public {}

    
    function setlatestanswer(int256 answer, uint256 timestamp) external {
        roundid++;
        entries[roundid] = entry({
            roundid: roundid,
            answer: answer,
            startedat: timestamp,
            updatedat: timestamp,
            answeredinround: roundid
        });
    }

    function setlatestanswerwithround(
        int256 answer,
        uint256 timestamp,
        uint80 _roundid
    ) external {
        roundid = _roundid;
        entries[roundid] = entry({
            roundid: roundid,
            answer: answer,
            startedat: timestamp,
            updatedat: timestamp,
            answeredinround: roundid
        });
    }

    function setdecimals(uint8 _decimals) external {
        keydecimals = _decimals;
    }

    function latestrounddata()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        return getrounddata(uint80(latestround()));
    }

    function latestround() public view returns (uint256) {
        return roundid;
    }

    function decimals() external view returns (uint8) {
        return keydecimals;
    }

    function getrounddata(uint80 _roundid)
        public
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        entry memory entry = entries[_roundid];
        return (entry.roundid, entry.answer, entry.startedat, entry.updatedat, entry.answeredinround);
    }
}
