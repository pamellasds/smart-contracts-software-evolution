pragma solidity ^0.4.11;
import ;
import ;

contract bancorformula is ibancorformula, safemath {

    uint256[128] maxexparray;
    uint256 constant uint1 = 1;
    uint256 constant uint2 = 2;
    uint256 constant uint3 = 3;
    uint8 constant min_precision = 32;
    uint8 constant max_precision = 95;
    string public version = ;

    function bancorformula() {
































        maxexparray[ 32] = 0x386bfdba29;
        maxexparray[ 33] = 0x6c3390ecc8;
        maxexparray[ 34] = 0xcf8014760f;
        maxexparray[ 35] = 0x18ded91f0e7;
        maxexparray[ 36] = 0x2fb1d8fe082;
        maxexparray[ 37] = 0x5b771955b36;
        maxexparray[ 38] = 0xaf67a93bb50;
        maxexparray[ 39] = 0x15060c256cb2;
        maxexparray[ 40] = 0x285145f31ae5;
        maxexparray[ 41] = 0x4d5156639708;
        maxexparray[ 42] = 0x944620b0e70e;
        maxexparray[ 43] = 0x11c592761c666;
        maxexparray[ 44] = 0x2214d10d014ea;
        maxexparray[ 45] = 0x415bc6d6fb7dd;
        maxexparray[ 46] = 0x7d56e76777fc5;
        maxexparray[ 47] = 0xf05dc6b27edad;
        maxexparray[ 48] = 0x1ccf4b44bb4820;
        maxexparray[ 49] = 0x373fc456c53bb7;
        maxexparray[ 50] = 0x69f3d1c921891c;
        maxexparray[ 51] = 0xcb2ff529eb71e4;
        maxexparray[ 52] = 0x185a82b87b72e95;
        maxexparray[ 53] = 0x2eb40f9f620fda6;
        maxexparray[ 54] = 0x5990681d961a1ea;
        maxexparray[ 55] = 0xabc25204e02828d;
        maxexparray[ 56] = 0x14962dee9dc97640;
        maxexparray[ 57] = 0x277abdcdab07d5a7;
        maxexparray[ 58] = 0x4bb5ecca963d54ab;
        maxexparray[ 59] = 0x9131271922eaa606;
        maxexparray[ 60] = 0x116701e6ab0cd188d;
        maxexparray[ 61] = 0x215f77c045fbe8856;
        maxexparray[ 62] = 0x3ffffffffffffffff;
        maxexparray[ 63] = 0x7abbf6f6abb9d087f;
        maxexparray[ 64] = 0xeb5ec597592befbf4;
        maxexparray[ 65] = 0x1c35fedd14b861eb04;
        maxexparray[ 66] = 0x3619c87664579bc94a;
        maxexparray[ 67] = 0x67c00a3b07ffc01fd6;
        maxexparray[ 68] = 0xc6f6c8f8739773a7a4;
        maxexparray[ 69] = 0x17d8ec7f04136f4e561;
        maxexparray[ 70] = 0x2dbb8caad9b7097b91a;
        maxexparray[ 71] = 0x57b3d49dda84556d6f6;
        maxexparray[ 72] = 0xa830612b6591d9d9e61;
        maxexparray[ 73] = 0x1428a2f98d728ae223dd;
        maxexparray[ 74] = 0x26a8ab31cb8464ed99e1;
        maxexparray[ 75] = 0x4a23105873875bd52dfd;
        maxexparray[ 76] = 0x8e2c93b0e33355320ead;
        maxexparray[ 77] = 0x110a688680a7530515f3e;
        maxexparray[ 78] = 0x20ade36b7dbeeb8d79659;
        maxexparray[ 79] = 0x3eab73b3bbfe282243ce1;
        maxexparray[ 80] = 0x782ee3593f6d69831c453;
        maxexparray[ 81] = 0xe67a5a25da41063de1495;
        maxexparray[ 82] = 0x1b9fe22b629ddbbcdf8754;
        maxexparray[ 83] = 0x34f9e8e490c48e67e6ab8b;
        maxexparray[ 84] = 0x6597fa94f5b8f20ac16666;
        maxexparray[ 85] = 0xc2d415c3db974ab32a5184;
        maxexparray[ 86] = 0x175a07cfb107ed35ab61430;
        maxexparray[ 87] = 0x2cc8340ecb0d0f520a6af58;
        maxexparray[ 88] = 0x55e129027014146b9e37405;
        maxexparray[ 89] = 0xa4b16f74ee4bb2040a1ec6c;
        maxexparray[ 90] = 0x13bd5ee6d583ead3bd636b5c;
        maxexparray[ 91] = 0x25daf6654b1eaa55fd64df5e;
        maxexparray[ 92] = 0x4898938c9175530325b9d116;
        maxexparray[ 93] = 0x8b380f3558668c46c91c49a2;
        maxexparray[ 94] = 0x10afbbe022fdf442b2a522507;
        maxexparray[ 95] = 0x1ffffffffffffffffffffffff;
































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
        temp2 = safemul(_reservebalance, uint1 << precision);
        return safesub(temp1, temp2) / resn;
    }

    
    function calculatebestprecision(uint256 _basen, uint256 _based, uint256 _expn, uint256 _expd) constant returns (uint8) {
        uint256 maxval = lnupperbound(_basen, _based) * _expn;
		uint8 lo = min_precision;
		uint8 hi = max_precision;
		while (lo + 1 < hi) {
			uint8 mid = (lo + hi) / 2;
			if ((maxval << (mid  min_precision)) / _expd <= maxexparray[mid])
				lo = mid;
			else
				hi = mid;
		}
		if ((maxval << (hi  min_precision)) / _expd <= maxexparray[hi])
			return hi;
		else
			return lo;
    }

    
    function power(uint256 _basen, uint256 _based, uint256 _expn, uint256 _expd, uint8 _precision) constant returns (uint256) {
        uint256 logbase = ln(_basen, _based, _precision);
        
        
        
        return fixedexp(safemul(logbase, _expn) / _expd, _precision);
    }

    
    function ln(uint256 _numerator, uint256 _denominator, uint8 _precision) public constant returns (uint256) {
        assert(0 < _denominator && _denominator <= _numerator && _numerator < (uint1 << (256  _precision)));
        return fixedloge( (_numerator << _precision) / _denominator, _precision);
    }

    
    function lnupperbound(uint256 _basen, uint256 _based) constant returns (uint256) {
        assert(_basen > _based);

        uint256 scaledbasen = _basen << min_precision;
        if (scaledbasen <= _based *  0x2b7e15162) 
            return uint1 << min_precision;
        if (scaledbasen <= _based *  0x763992e35) 
            return uint2 << min_precision;
        if (scaledbasen <= _based * 0x1415e5bf6f) 
            return uint3 << min_precision;

        return ceillog2(_basen, _based) * 0xb17217f8;
    }

    
    function fixedloge(uint256 _x, uint8 _precision) constant returns (uint256) {
        
        assert(_x >= uint1 << _precision);

        uint256 log2 = fixedlog2(_x, _precision);
        return (log2 * 0xb17217f7d1cf78) >> 56;
    }

    
    function fixedlog2(uint256 _x, uint8 _precision) constant returns (uint256) {
        uint256 fixedone = uint1 << _precision;
        uint256 fixedtwo = uint2 << _precision;

        
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
                hi += uint1 << (_precision  1  i);
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
            if (_n >= (uint1 << s)) {
                _n >>= s;
                t |= s;
            }
        }

        return t;
    }

    
    function fixedexp(uint256 _x, uint8 _precision) constant returns (uint256) {
        assert(_x <= maxexparray[_precision]);
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
