pragma solidity ^0.4.11;
import ;
import ;



contract bancorformula is ibancorformula, safemath {

    uint256 constant one = 1;
    uint256 constant two = 2;
    uint256 constant max_fixed_exp_32 = 0x386bfdba29;
    string public version = ;

    function bancorformula() {
    }

    
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint8 _reserveratio, uint256 _depositamount) public constant returns (uint256) {
        
        require(_supply != 0 && _reservebalance != 0 && _reserveratio > 0 && _reserveratio <= 100);

        
        if (_depositamount == 0)
            return 0;

        uint256 basen = safeadd(_depositamount, _reservebalance);
        uint256 temp;

        
        if (_reserveratio == 100) {
            temp = safemul(_supply, basen) / _reservebalance;
            return safesub(temp, _supply); 
        }

        uint8 precision = calculatebestprecision(basen, _reservebalance, _reserveratio, 100);
        uint256 resn = power(basen, _reservebalance, _reserveratio, 100, precision);
        temp = safemul(_supply, resn) >> precision;
        return safesub(temp, _supply);
     }

    
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint8 _reserveratio, uint256 _sellamount) public constant returns (uint256) {
        
        require(_supply != 0 && _reservebalance != 0 && _reserveratio > 0 && _reserveratio <= 100 && _sellamount <= _supply);

        
        if (_sellamount == 0)
            return 0;

        uint256 based = safesub(_supply, _sellamount);
        uint256 temp1;
        uint256 temp2;

        
        if (_reserveratio == 100) {
            temp1 = safemul(_reservebalance, _supply);
            temp2 = safemul(_reservebalance, based);
            return safesub(temp1, temp2) / _supply;
        }

        
        if (_sellamount == _supply)
            return _reservebalance;

        uint8 precision = calculatebestprecision(_supply, based, 100, _reserveratio);
        uint256 resn = power(_supply, based, 100, _reserveratio, precision);
        temp1 = safemul(_reservebalance, resn);
        temp2 = safemul(_reservebalance, one << precision);
        return safesub(temp1, temp2) / resn;
    }

    
    function calculatebestprecision(uint256 _basen, uint256 _based, uint256 _expn, uint256 _expd) constant returns (uint8) {
        uint8 precision;
        uint256 maxexp = max_fixed_exp_32;
        uint256 maxval = lnupperbound32(_basen,_based) * _expn;
        for (precision = 0; precision < 32; precision += 2) {
            if (maxexp < (maxval << precision) / _expd)
                break;
            maxexp = (maxexp * 0xeb5ec5975959c565) >> (642);
        }
        if (precision == 0)
            return 32;
        return precision+322;
    }

     
    function power(uint256 _basen, uint256 _based, uint256 _expn, uint256 _expd, uint8 _precision) constant returns (uint256) {
        uint256 logbase = ln(_basen, _based, _precision);
        
        
        
        return fixedexp(safemul(logbase, _expn) / _expd, _precision);
    }
    
    
    function ln(uint256 _numerator, uint256 _denominator, uint8 _precision) public constant returns (uint256) {
        
        assert(0 < _denominator && _denominator <= _numerator && _numerator < (one << (256  _precision)));

        return fixedloge( (_numerator << _precision) / _denominator, _precision);
    }

    
    function lnupperbound32(uint256 _basen, uint256 _based) constant returns (uint256) {
        assert(_basen > _based);

        uint256 scaledbasen = _basen << 32;
        if (scaledbasen <= _based *  0x2b7e15162) 
            return uint256(1) << 32;
        if (scaledbasen <= _based *  0x763992e35) 
            return uint256(2) << 32;
        if (scaledbasen <= _based * 0x1415e5bf6f) 
            return uint256(3) << 32;

        return ceillog2(_basen, _based) * 0xb17217f8;
    }

    
    function fixedloge(uint256 _x, uint8 _precision) constant returns (uint256) {
        
        assert(_x >= one << _precision);

        uint256 log2 = fixedlog2(_x, _precision);
        return (log2 * 0xb17217f7d1cf78) >> 56;
    }

    
    function fixedlog2(uint256 _x, uint8 _precision) constant returns (uint256) {
        uint256 fixedone = one << _precision;
        uint256 fixedtwo = two << _precision;

        
        assert( _x >= fixedone);

        uint256 hi = 0;
        while (_x >= fixedtwo) {
            _x >>= 1;
            hi += fixedone;
        }

        for (uint8 i = 0; i < _precision; ++i) {
            _x = (_x * _x) / fixedone;
            if (_x >= fixedtwo) {
                _x >>= 1;
                hi += one << (_precision  1  i);
            }
        }

        return hi;
    }

    
    function ceillog2(uint256 _basen, uint256 _based) constant returns (uint256) {
        return floorlog2((_basen  1) / _based) + 1;
    }

    
    function floorlog2(uint256 _n) constant returns (uint256) {
        uint8 t = 0;
        for (uint8 s = 128; s > 0; s >>= 1) {
            if (_n >= (one << s)) {
                _n >>= s;
                t |= s;
            }
        }

        return t;
    }

    
    function fixedexp(uint256 _x, uint8 _precision) constant returns (uint256) {
        uint256 maxexp = max_fixed_exp_32;
        for (uint8 p = 32; p < _precision; p += 2)
            maxexp = (maxexp * 0xeb5ec5975959c565) >> (642);
        
        assert(_x <= maxexp);
        return fixedexpunsafe(_x, _precision);
    }

    
    function fixedexpunsafe(uint256 _x, uint8 _precision) constant returns (uint256) {
        uint256 xi = _x;
        uint256 res = uint256(0xde1bc4d19efcac82445da75b00000000) << _precision;

        res += xi * 0xde1bc4d19efcac82445da75b00000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x6f0de268cf7e5641222ed3ad80000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x2504a0cd9a7f7215b60f9be480000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x9412833669fdc856d83e6f920000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x1d9d4d714865f4de2b3fafea0000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x4ef8ce836bba8cfb1dff2a70000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0xb481d807d1aa66d04490610000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x16903b00fa354cda08920c2000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x281cdaac677b334ab9e732000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x402e2aad725eb8778fd85000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x5d5a6c9f31fe2396a2af000000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x7c7890d442a82f73839400000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x9931ed54034526b58e400000;
        xi = (xi * _x) >> _precision;
        res += xi * 0xaf147cf24ce150cf7e00000;
        xi = (xi * _x) >> _precision;
        res += xi * 0xbac08546b867cdaa200000;
        xi = (xi * _x) >> _precision;
        res += xi * 0xbac08546b867cdaa20000;
        xi = (xi * _x) >> _precision;
        res += xi * 0xafc441338061b2820000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x9c3cabbc0056d790000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x839168328705c30000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x694120286c049c000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x50319e98b3d2c000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x3a52a1e36b82000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x289286e0fce000;
        xi = (xi * _x) >> _precision;
        res += xi * 0x1b0c59eb53400;
        xi = (xi * _x) >> _precision;
        res += xi * 0x114f95b55400;
        xi = (xi * _x) >> _precision;
        res += xi * 0xaa7210d200;
        xi = (xi * _x) >> _precision;
        res += xi * 0x650139600;
        xi = (xi * _x) >> _precision;
        res += xi * 0x39b78e80;
        xi = (xi * _x) >> _precision;
        res += xi * 0x1fd8080;
        xi = (xi * _x) >> _precision;
        res += xi * 0x10fbc0;
        xi = (xi * _x) >> _precision;
        res += xi * 0x8c40;
        xi = (xi * _x) >> _precision;
        res += xi * 0x462;
        xi = (xi * _x) >> _precision;
        res += xi * 0x22;

        return res / 0xde1bc4d19efcac82445da75b00000000;
    }
}
