pragma solidity ^0.5.16;

import ;



library safedecimalmath {
    using safemath for uint;

    
    uint8 public constant decimals = 18;
    uint8 public constant highprecisiondecimals = 27;

    
    uint public constant unit = 10**uint(decimals);

    
    uint public constant precise_unit = 10**uint(highprecisiondecimals);
    uint private constant unit_to_high_precision_conversion_factor = 10**uint(highprecisiondecimals  decimals);

    
    function unit() external pure returns (uint) {
        return unit;
    }

    
    function preciseunit() external pure returns (uint) {
        return precise_unit;
    }

    
    function multiplydecimal(uint x, uint y) internal pure returns (uint) {
        
        return x.mul(y) / unit;
    }

    
    function _multiplydecimalround(
        uint x,
        uint y,
        uint precisionunit
    ) private pure returns (uint) {
        
        uint quotienttimesten = x.mul(y) / (precisionunit / 10);

        if (quotienttimesten % 10 >= 5) {
            quotienttimesten += 10;
        }

        return quotienttimesten / 10;
    }

    
    function multiplydecimalroundprecise(uint x, uint y) internal pure returns (uint) {
        return _multiplydecimalround(x, y, precise_unit);
    }

    
    function multiplydecimalround(uint x, uint y) internal pure returns (uint) {
        return _multiplydecimalround(x, y, unit);
    }

    
    function dividedecimal(uint x, uint y) internal pure returns (uint) {
        
        return x.mul(unit).div(y);
    }

    
    function _dividedecimalround(
        uint x,
        uint y,
        uint precisionunit
    ) private pure returns (uint) {
        uint resulttimesten = x.mul(precisionunit * 10).div(y);

        if (resulttimesten % 10 >= 5) {
            resulttimesten += 10;
        }

        return resulttimesten / 10;
    }

    
    function dividedecimalround(uint x, uint y) internal pure returns (uint) {
        return _dividedecimalround(x, y, unit);
    }

    
    function dividedecimalroundprecise(uint x, uint y) internal pure returns (uint) {
        return _dividedecimalround(x, y, precise_unit);
    }

    
    function decimaltoprecisedecimal(uint i) internal pure returns (uint) {
        return i.mul(unit_to_high_precision_conversion_factor);
    }

    
    function precisedecimaltodecimal(uint i) internal pure returns (uint) {
        uint quotienttimesten = i / (unit_to_high_precision_conversion_factor / 10);

        if (quotienttimesten % 10 >= 5) {
            quotienttimesten += 10;
        }

        return quotienttimesten / 10;
    }
}
