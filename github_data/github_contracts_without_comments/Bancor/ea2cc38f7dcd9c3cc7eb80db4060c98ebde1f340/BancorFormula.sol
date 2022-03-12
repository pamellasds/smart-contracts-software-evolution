pragma solidity ^0.4.8;
import ;



contract bancorformula is owned {
    uint8 constant precision = 32;  

    string public version = ;
    address public newformula;

    function bancorformula() {
    }

    function setnewformula(address _formula) public onlyowner {
        newformula = _formula;
    }

    
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _depositamount) public constant returns (uint256 amount) {
        if (_supply == 0 || _reservebalance == 0 || _reserveratio < 1 || _reserveratio > 100 || _depositamount == 0) 
            throw;
        
        
        if (_supply > uint128(1) || _reservebalance > uint128(1) || _depositamount > uint128(1))
            throw;

        
        if (_reserveratio == 100)
            return _supply * (_reservebalance + _depositamount) / _reservebalance  _supply;

        var (resn, resd) = power(uint128(_depositamount + _reservebalance), uint128(_reservebalance), _reserveratio, 100);
        return (_supply * resn / resd)  _supply;
    }

    
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256 amount) {
        if (_supply == 0 || _reservebalance == 0 || _reserveratio < 1 || _reserveratio > 100 || _sellamount == 0) 
            throw;
        
        
        if (_supply > uint128(1) || _reservebalance > uint128(1) || _sellamount > uint128(1))
            throw;

        
        if (_reserveratio == 100)
            return _reservebalance * (_supply + _sellamount) / _supply  _reservebalance;

        var (resn, resd) = power(uint128(_sellamount + _supply), uint128(_supply), 100, _reserveratio);
        return (_reservebalance * resn / resd)  _reservebalance;
    }

    function power(uint128 _basen, uint128 _based, uint32 _expn, uint32 _expd) private returns (uint256 resn, uint256 resd) {
        return (fixedexp(ln(_basen, _based) * _expn / _expd), uint256(1) << precision);
	}
    
    function ln(uint128 _numerator, uint128 _denominator) private returns (uint256) {
        return fixedloge(uint256(_numerator) << precision)  fixedloge(uint256(_denominator) << precision);
    }

    function fixedloge(uint256 _x) private returns (uint256) {
        return (fixedlog2(_x) * 1488522236) >> 31; 
    }

    function fixedlog2(uint256 _x) private returns (uint256) {
        uint256 fixedone = uint256(1) << precision;
        uint256 fixedtwo = uint256(2) << precision;

        uint256 lo = 0;
        uint256 hi = 0;

        while (_x < fixedone) {
            _x <<= 1;
            lo += fixedone;
        }

        while (_x >= fixedtwo) {
            _x >>= 1;
            hi += fixedone;
        }

        for (uint8 i = 0; i < precision; ++i) {
            _x = (_x * _x) >> precision;
            if (_x >= fixedtwo) {
                _x >>= 1;
                hi += uint256(1) << (precision  1  i);
            }
        }

        return hi  lo;
    }
    
    function fixedexp(uint256 _x) private returns (uint256) {
        uint256 fixedone = uint256(1) << precision;

        
		uint256[34 + 1] memory ni;
		ni[0] = 295232799039604140847618609643520000000;
		for (uint8 n = 1; n < ni.length; ++n)
		    ni[n] = ni[n  1] / n;

		uint256 res = ni[0] << precision;
		uint256 xi = fixedone;
		for (uint8 i = 1; i < ni.length; ++i) {
    	    xi = (xi * _x) >> precision;
			res += xi * ni[i];
		}

		return res / ni[0];
    }

    function() {
        throw;
    }
}
