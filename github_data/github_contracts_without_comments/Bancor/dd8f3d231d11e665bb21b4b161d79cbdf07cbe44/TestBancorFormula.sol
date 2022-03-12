pragma solidity ^0.4.11;
import ;


contract testbancorformula is bancorformula {
    function testbancorformula() {
    }

    function testfixedexp(uint256 _x, uint8 _precision) public constant returns (uint256) {
        return super.fixedexp(_x, _precision);
    }

    function testfixedexpunsafe(uint256 _x, uint8 _precision) public constant returns (uint256) {
        return super.fixedexpunsafe(_x, _precision);
    }
}
