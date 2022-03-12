
pragma solidity 0.6.12;
import ;

contract testmath {
    using math for *;

    function floorsqrttest(uint256 _num) external pure returns (uint256) {
        return math.floorsqrt(_num);
    }

    function reducedratiotest(uint256 _n, uint256 _d, uint256 _max) external pure returns (uint256, uint256) {
        return math.reducedratio(_n, _d, _max);
    }

    function normalizedratiotest(uint256 _a, uint256 _b, uint256 _scale) external pure returns (uint256, uint256) {
        return math.normalizedratio(_a, _b, _scale);
    }

    function accurateratiotest(uint256 _a, uint256 _b, uint256 _scale) external pure returns (uint256, uint256) {
        return math.accurateratio(_a, _b, _scale);
    }

    function rounddivtest(uint256 _n, uint256 _d) external pure returns (uint256) {
        return math.rounddiv(_n, _d);
    }
}
