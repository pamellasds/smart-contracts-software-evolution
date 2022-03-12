pragma solidity ^0.4.21;
import ;
import ;
import ;
import ;
import ;


contract bancorquickconverter is ibancorquickconverter, tokenholder {
    address public signeraddress = 0x0; 
    ibancorgaspricelimit public gaspricelimit; 
    mapping (address => bool) public ethertokens;   
    mapping (bytes32 => bool) public conversionhashes;

    
    function bancorquickconverter() public {
    }

    
    modifier validconversionpath(ierc20token[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

    
    function setgaspricelimit(ibancorgaspricelimit _gaspricelimit)
        public
        owneronly
        validaddress(_gaspricelimit)
        notthis(_gaspricelimit)
    {
        gaspricelimit = _gaspricelimit;
    }

    
    function setsigneraddress(address _signeraddress)
        public
        owneronly
        validaddress(_signeraddress)
        notthis(_signeraddress)
    {
        signeraddress = _signeraddress;
    }

    
    function registerethertoken(iethertoken _token, bool _register)
        public
        owneronly
        validaddress(_token)
        notthis(_token)
    {
        ethertokens[_token] = _register;
    }

    
    function verifytrustedsender(uint256 _block, address _addr, uint256 _nonce, uint8 _v, bytes32 _r, bytes32 _s) private returns(bool) {
        bytes32 hash = sha256(_block, tx.gasprice, _addr, _nonce);

        
        
        
        require(!conversionhashes[hash] && block.number <= _block);

        
        
        bytes memory prefix = ;
        bytes32 prefixedhash = keccak256(prefix, hash);
        bool verified = ecrecover(prefixedhash, _v, _r, _s) == signeraddress;

        
        
        if (verified)
            conversionhashes[hash] = true;
        return verified;
    }


    function convertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for) public payable returns (uint256) {
        return convertforprioritized(_path, _amount, _minreturn, _for, 0x0, 0x0, 0x0, 0x0, 0x0);
    }

    
    function convertforprioritized(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for, uint256 _block, uint256 _nonce, uint8 _v, bytes32 _r, bytes32 _s)
        public
        payable
        validconversionpath(_path)
        returns (uint256)
    {
        if (_v == 0x0 && _r == 0x0 && _s == 0x0)
            gaspricelimit.validategasprice(tx.gasprice);
        else
            require(verifytrustedsender(_block, _for, _nonce, _v, _r, _s));

        
        ierc20token fromtoken = _path[0];
        require(msg.value == 0 || (_amount == msg.value && ethertokens[fromtoken]));

        ierc20token totoken;

        
        
        if (msg.value > 0)
            iethertoken(fromtoken).deposit.value(msg.value)();
        
        (_amount, totoken) = convertbypath(_path, _amount, _minreturn, fromtoken);

        
        
        
        if (ethertokens[totoken])
            iethertoken(totoken).withdrawto(_for, _amount);
        else
            assert(totoken.transfer(_for, _amount));

        return _amount;
    }

    function convertbypath(ierc20token[] _path, uint256 _amount, uint256 _minreturn, ierc20token _fromtoken) private returns (uint256, ierc20token) {
        ismarttoken smarttoken;
        ierc20token totoken;
        itokenconverter converter;

        
        uint256 pathlength = _path.length;

        for (uint256 i = 1; i < pathlength; i += 2) {
            smarttoken = ismarttoken(_path[i]);
            totoken = _path[i + 1];
            converter = itokenconverter(smarttoken.owner());

            
            if (smarttoken != _fromtoken)
                ensureallowance(_fromtoken, converter, _amount);

            
            _amount = converter.change(_fromtoken, totoken, _amount, i == pathlength  2 ? _minreturn : 1);
            _fromtoken = totoken;
        }
        return (_amount, totoken);
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
