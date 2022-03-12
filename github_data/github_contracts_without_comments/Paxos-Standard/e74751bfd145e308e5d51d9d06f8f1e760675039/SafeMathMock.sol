pragma solidity ^0.4.24;


import ;


contract safemathmock {
    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        return safemath.sub(a, b);
    }

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return safemath.add(a, b);
    }
}
