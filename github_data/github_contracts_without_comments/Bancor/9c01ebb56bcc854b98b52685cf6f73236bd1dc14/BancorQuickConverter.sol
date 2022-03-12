pragma solidity ^0.4.11;
import ;
import ;
import ;
import ;


contract bancorquickconverter is ibancorquickconverter, utils {
    
    function bancorquickconverter() {
    }

    
    modifier validconversionpath(ierc20token[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

    
    function convert(ierc20token[] _path, uint256 _amount, uint256 _minreturn)
        public
        validconversionpath(_path)
        returns (uint256)
    {
        
        
        
        ierc20token fromtoken = _path[0];
        assert(fromtoken.transferfrom(msg.sender, this, _amount));

        ismarttoken smarttoken;
        ierc20token totoken;
        itokenconverter converter;
        uint256 pathlength = _path.length;

        
        for (uint256 i = 1; i < pathlength; i += 2) {
            smarttoken = ismarttoken(_path[i]);
            totoken = _path[i + 1];
            converter = itokenconverter(smarttoken.owner());

            
            if (smarttoken != fromtoken)
                ensureallowance(fromtoken, converter, _amount);

            
            _amount = converter.change(fromtoken, totoken, _amount, i == pathlength  2 ? _minreturn : 1);
            fromtoken = totoken;
        }

        assert(totoken.transfer(msg.sender, _amount));
        return _amount;
    }

    
    function ensureallowance(ierc20token _token, address _spender, uint256 _value) private {
        
        if (_token.allowance(this, _spender) >= _value)
            return;

        
        if (_token.allowance(this, _spender) != 0)
            assert(_token.approve(_spender, 0));

        
        assert(_token.approve(_spender, _value));
    }
}
