pragma solidity ^0.4.18;
import ;
import ;
import ;
import ;
import ;


contract bancorquickconverter is ibancorquickconverter, tokenholder {
    mapping (address => bool) public ethertokens;   

    
    function bancorquickconverter() public {
    }

    
    modifier validconversionpath(ierc20token[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

    
    function registerethertoken(iethertoken _token, bool _register)
        public
        owneronly
        validaddress(_token)
        notthis(_token)
    {
        ethertokens[_token] = _register;
    }

    
    function convertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for)
        public
        payable
        validconversionpath(_path)
        returns (uint256)
    {
        
        ierc20token fromtoken = _path[0];
        require(msg.value == 0 || (_amount == msg.value && ethertokens[fromtoken]));

        ismarttoken smarttoken;
        ierc20token totoken;
        itokenconverter converter;
        uint256 pathlength = _path.length;

        
        
        if (msg.value > 0)
            iethertoken(fromtoken).deposit.value(msg.value)();

        
        for (uint256 i = 1; i < pathlength; i += 2) {
            smarttoken = ismarttoken(_path[i]);
            totoken = _path[i + 1];
            converter = itokenconverter(smarttoken.owner());

            
            if (smarttoken != fromtoken)
                ensureallowance(fromtoken, converter, _amount);

            
            _amount = converter.change(fromtoken, totoken, _amount, i == pathlength  2 ? _minreturn : 1);
            fromtoken = totoken;
        }

        
        
        
        if (ethertokens[totoken])
            iethertoken(totoken).withdrawto(_for, _amount);
        else
            assert(totoken.transfer(_for, _amount));

        return _amount;
    }

    
    function claimandconvertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for) public returns (uint256) {
        
        
        
        ierc20token fromtoken = _path[0];
        assert(fromtoken.transferfrom(msg.sender, this, _amount));
        return convertfor(_path, _amount, _minreturn, _for);
    }

    
    function convert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public payable returns (uint256) {
        return convertfor(_path, _amount, _minreturn, msg.sender);
    }

    
    function claimandconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return claimandconvertfor(_path, _amount, _minreturn, msg.sender);
    }

    
    function ensureallowance(ierc20token _token, address _spender, uint256 _value) private {
        
        if (_token.allowance(this, _spender) >= _value)
            return;

        
        if (_token.allowance(this, _spender) != 0)
            assert(_token.approve(_spender, 0));

        
        assert(_token.approve(_spender, _value));
    }
}
