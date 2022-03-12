pragma solidity 0.4.26;
import ;


contract testsafemath {
    using safemath for uint256;

    function testsafeadd(uint256 _x, uint256 _y) public pure returns (uint256) {
        return _x.add(_y);
    }

    function testsafesub(uint256 _x, uint256 _y) public pure returns (uint256) {
        return _x.sub(_y);
    }

    function testsafemul(uint256 _x, uint256 _y) public pure returns (uint256) {
        return _x.mul(_y);
    }

    function testsafediv(uint256 _x, uint256 _y) public pure returns (uint256) {
        return _x.div(_y);
    }
}
