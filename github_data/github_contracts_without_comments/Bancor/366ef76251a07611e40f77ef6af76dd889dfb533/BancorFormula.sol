pragma solidity ^0.4.11;
import ;
import ;



contract bancorformula is ibancorformula, safemath {

    uint8 constant precision   = 32;  
    uint256 constant fixed_one = uint256(1) << precision; 
    uint256 constant fixed_two = uint256(2) << precision; 
    uint256 constant max_val   = uint256(1) << (256  precision); 
    string public version = ;

    function bancorformula() {
    }

    
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _depositamount) public constant returns (uint256) {
        
        require(_supply != 0 && _reservebalance != 0 && _reserveratio > 0 && _reserveratio <= 100);

        
        if (_depositamount == 0)
            return 0;

        uint256 basen = safeadd(_depositamount, _reservebalance);
        uint256 temp;

        
        if (_reserveratio == 100) {
            temp = safemul(_supply, basen) / _reservebalance;
            return safesub(temp, _supply); 
        }

        uint256 resn = power(basen, _reservebalance, _reserveratio, 100);

        temp = safemul(_supply, resn) / fixed_one;

        return safesub(temp, _supply);
     }

    
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256) {
        
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

        uint256 resn = power(_supply, based, 100, _reserveratio);

        temp1 = safemul(_reservebalance, resn);
        temp2 = safemul(_reservebalance, fixed_one);

        return safesub(temp1, temp2) / resn;
    }

     
    function power(uint256 _basen, uint256 _based, uint32 _expn, uint32 _expd) constant returns (uint256 resn) {
        uint256 logbase = ln(_basen, _based);
        
        
        
        resn = fixedexp(safemul(logbase, _expn) / _expd);
        return resn;
	}
    
    
    function ln(uint256 _numerator, uint256 _denominator) public constant returns (uint256) {
        
        assert(_denominator <= _numerator);

        
        assert(_denominator != 0 && _numerator != 0);

        
        assert(_numerator < max_val);
        assert(_denominator < max_val);

        return fixedloge( (_numerator * fixed_one) / _denominator);
    }

    
    function fixedloge(uint256 _x) constant returns (uint256 loge) {
        
        
        assert(_x >= fixed_one);

        uint256 log2 = fixedlog2(_x);
        loge = (log2 * 0xb17217f7d1cf78) >> 56;
    }

    
    function fixedlog2(uint256 _x) constant returns (uint256) {
        
        assert( _x >= fixed_one);

        uint256 hi = 0;
        while (_x >= fixed_two) {
            _x >>= 1;
            hi += fixed_one;
        }

        for (uint8 i = 0; i < precision; ++i) {
            _x = (_x * _x) / fixed_one;
            if (_x >= fixed_two) {
                _x >>= 1;
                hi += uint256(1) << (precision  1  i);
            }
        }

        return hi;
    }

    
    function fixedexp(uint256 _x) constant returns (uint256) {
        assert(_x <= 0x386bfdba29);
        return fixedexpunsafe(_x);
    }

    
    function fixedexpunsafe(uint256 _x) constant returns (uint256) {
    
        uint256 xi = fixed_one;
        uint256 res = 0xde1bc4d19efcac82445da75b00000000 * xi;

        xi = (xi * _x) >> precision;
        res += xi * 0xde1bc4d19efcac82445da75b00000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x6f0de268cf7e5641222ed3ad80000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x2504a0cd9a7f7215b60f9be480000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x9412833669fdc856d83e6f920000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x1d9d4d714865f4de2b3fafea0000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x4ef8ce836bba8cfb1dff2a70000000;
        xi = (xi * _x) >> precision;
        res += xi * 0xb481d807d1aa66d04490610000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x16903b00fa354cda08920c2000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x281cdaac677b334ab9e732000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x402e2aad725eb8778fd85000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x5d5a6c9f31fe2396a2af000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x7c7890d442a82f73839400000;
        xi = (xi * _x) >> precision;
        res += xi * 0x9931ed54034526b58e400000;
        xi = (xi * _x) >> precision;
        res += xi * 0xaf147cf24ce150cf7e00000;
        xi = (xi * _x) >> precision;
        res += xi * 0xbac08546b867cdaa200000;
        xi = (xi * _x) >> precision;
        res += xi * 0xbac08546b867cdaa20000;
        xi = (xi * _x) >> precision;
        res += xi * 0xafc441338061b2820000;
        xi = (xi * _x) >> precision;
        res += xi * 0x9c3cabbc0056d790000;
        xi = (xi * _x) >> precision;
        res += xi * 0x839168328705c30000;
        xi = (xi * _x) >> precision;
        res += xi * 0x694120286c049c000;
        xi = (xi * _x) >> precision;
        res += xi * 0x50319e98b3d2c000;
        xi = (xi * _x) >> precision;
        res += xi * 0x3a52a1e36b82000;
        xi = (xi * _x) >> precision;
        res += xi * 0x289286e0fce000;
        xi = (xi * _x) >> precision;
        res += xi * 0x1b0c59eb53400;
        xi = (xi * _x) >> precision;
        res += xi * 0x114f95b55400;
        xi = (xi * _x) >> precision;
        res += xi * 0xaa7210d200;
        xi = (xi * _x) >> precision;
        res += xi * 0x650139600;
        xi = (xi * _x) >> precision;
        res += xi * 0x39b78e80;
        xi = (xi * _x) >> precision;
        res += xi * 0x1fd8080;
        xi = (xi * _x) >> precision;
        res += xi * 0x10fbc0;
        xi = (xi * _x) >> precision;
        res += xi * 0x8c40;
        xi = (xi * _x) >> precision;
        res += xi * 0x462;
        xi = (xi * _x) >> precision;
        res += xi * 0x22;

        return res / 0xde1bc4d19efcac82445da75b00000000;
    }
}
