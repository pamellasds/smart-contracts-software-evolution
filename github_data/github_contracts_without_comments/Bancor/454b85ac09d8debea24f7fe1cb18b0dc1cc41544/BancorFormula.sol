pragma solidity ^0.4.11;
import ;
import ;



contract bancorformula is ibancorformula, safemath {

    uint8 constant precision   = 32;  
    uint256 constant fixed_one = uint256(1) << precision; 
    uint256 constant fixed_two = uint256(2) << precision; 
    
    uint256 constant max_val   = uint256(1)<<(256precision);
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

        uint256 result =  safesub(temp, _supply);
        
        
        return safesub(result, _supply / 0x100000000);
     }

    
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256) {
        
        require(_supply != 0 && _reservebalance != 0 && _reserveratio > 0 && _reserveratio <= 100 && _sellamount <= _supply);

        
        if (_sellamount == 0)
            return 0;

        uint256 basen = safesub(_supply, _sellamount);
        uint256 temp1;
        uint256 temp2;

        
        if (_reserveratio == 100) {
            temp1 = safemul(_reservebalance, _supply);
            temp2 = safemul(_reservebalance, basen);
            return safesub(temp1, temp2) / _supply;
        }

        
        if (_sellamount == _supply)
            return _reservebalance;

        uint256 resn = power(_supply, basen, 100, _reserveratio);

        temp1 = safemul(_reservebalance, resn);
        temp2 = safemul(_reservebalance, fixed_one);

        uint256 result = safesub(temp1, temp2) / resn;

        
        
        return safesub(result, _reservebalance / 0x100000000);
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
        res += xi * 0xde1bc4d19efcb0000000000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x6f0de268cf7e58000000000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x2504a0cd9a7f72000000000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x9412833669fdc800000000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x1d9d4d714865f500000000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x4ef8ce836bba8c0000000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0xb481d807d1aa68000000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x16903b00fa354d000000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x281cdaac677b3400000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x402e2aad725eb80000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x5d5a6c9f31fe24000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x7c7890d442a83000000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x9931ed540345280000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0xaf147cf24ce150000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0xbac08546b867d000000000;
        xi = (xi * _x) >> precision;
        res += xi * 0xbac08546b867d00000000;
        xi = (xi * _x) >> precision;
        res += xi * 0xafc441338061b8000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x9c3cabbc0056e000000;
        xi = (xi * _x) >> precision;
        res += xi * 0x839168328705c80000;
        xi = (xi * _x) >> precision;
        res += xi * 0x694120286c04a0000;
        xi = (xi * _x) >> precision;
        res += xi * 0x50319e98b3d2c400;
        xi = (xi * _x) >> precision;
        res += xi * 0x3a52a1e36b82020;
        xi = (xi * _x) >> precision;
        res += xi * 0x289286e0fce002;
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
