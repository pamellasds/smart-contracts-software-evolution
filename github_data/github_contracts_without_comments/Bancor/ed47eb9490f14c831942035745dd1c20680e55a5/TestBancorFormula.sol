pragma solidity ^0.4.11;
import ;


contract testbancorformula is bancorformula {
    function testbancorformula() public {
    }

    function powertest(uint256 _basen, uint256 _based, uint32 _expn, uint32 _expd) public constant returns (uint256, uint8) {
        return super.power(_basen, _based, _expn, _expd);
    }

    function lntest(uint256 _numerator, uint256 _denominator) public pure returns (uint256) {
        return super.ln(_numerator, _denominator);
    }

    function findpositioninmaxexparraytest(uint256 _x) public constant returns (uint8) {
        return super.findpositioninmaxexparray(_x);
    }

    function fixedexptest(uint256 _x, uint8 _precision) public pure returns (uint256) {
        return super.fixedexp(_x, _precision);
    }

    function floorlog2test(uint256 _n) public pure returns (uint8) {
        return super.floorlog2(_n);
    }
}
