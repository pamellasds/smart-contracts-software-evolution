pragma solidity ^0.4.10;


contract safemath {
    function safemath() {
    }

    function safeadd(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

    function safesub(uint256 _x, uint256 _y) internal returns (uint256) {
        assert(_x >= _y);
        return _x  _y;
    }

    function safemul(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}
