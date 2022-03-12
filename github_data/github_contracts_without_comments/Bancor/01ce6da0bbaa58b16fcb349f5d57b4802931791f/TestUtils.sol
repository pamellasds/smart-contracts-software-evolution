pragma solidity ^0.4.24;
import ;


contract testutils is utils {
    constructor() public {
    }

    function testsafeadd(uint256 _x, uint256 _y) public pure returns (uint256) {
        return super.safeadd(_x, _y);
    }

    function testsafesub(uint256 _x, uint256 _y) public pure returns (uint256) {
        return super.safesub(_x, _y);
    }

    function testsafemul(uint256 _x, uint256 _y) public pure returns (uint256) {
        return super.safemul(_x, _y);
    }
}
