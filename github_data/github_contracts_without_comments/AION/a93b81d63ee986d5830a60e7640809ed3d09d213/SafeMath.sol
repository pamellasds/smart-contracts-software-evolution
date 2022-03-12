

pragma solidity >=0.4.10;


contract safemath {
    function safemul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safesub(uint a, uint b) internal returns (uint) {
        require(b <= a);
        return a  b;
    }

    function safeadd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        require(c>=a && c>=b);
        return c;
    }
}