pragma solidity ^0.4.23;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract bancornetwork is ibancornetwork, tokenholder, contractids, featureids {
    uint64 private constant max_conversion_fee = 1000000;

    address public signeraddress = 0x0;         
    icontractregistry public registry;          

    mapping (address => bool) public ethertokens;       
    mapping (bytes32 => bool) public conversionhashes;  

    
    constructor(icontractregistry _registry) public validaddress(_registry) {
        registry = _registry;
    }

    
    modifier validconversionpath(ierc20token[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

    
    function setregistry(icontractregistry _registry)
        public
        owneronly
        validaddress(_registry)
        notthis(_registry)
    {
        registry = _registry;
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

    
    function verifytrustedsender(ierc20token[] _path, uint256 _amount, uint256 _block, address _addr, uint8 _v, bytes32 _r, bytes32 _s) private returns(bool) {
        bytes32 hash = keccak256(_block, tx.gasprice, _addr, msg.sender, _amount, _path);

        
        
        
        require(!conversionhashes[hash] && block.number <= _block);

        
        
        bytes32 prefixedhash = keccak256(, hash);
        bool verified = ecrecover(prefixedhash, _v, _r, _s) == signeraddress;

        
        
        if (verified)
            conversionhashes[hash] = true;
        return verified;
    }

    
    function convertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for) public payable returns (uint256) {
        return convertforprioritized2(_path, _amount, _minreturn, _for, 0x0, 0x0, 0x0, 0x0);
    }

    
    function convertforprioritized2(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for, uint256 _block, uint8 _v, bytes32 _r, bytes32 _s)
        public
        payable
        validconversionpath(_path)
        returns (uint256)
    {
        
        ierc20token fromtoken = _path[0];
        require(msg.value == 0 || (_amount == msg.value && ethertokens[fromtoken]));

        
        
        if (msg.value > 0)
            iethertoken(fromtoken).deposit.value(msg.value)();

        return convertforinternal(_path, _amount, _minreturn, _for, _block, _v, _r, _s);
    }

    
    function convertformultiple(ierc20token[] _paths, uint256[] _pathstartindex, uint256[] _amounts, uint256[] _minreturns, address _for)
        public
        payable
        returns (uint256[])
    {
        
        uint256 convertedvalue = 0;
        uint256 pathendindex;
        
        
        for (uint256 i = 0; i < _pathstartindex.length; i += 1) {
            pathendindex = i == (_pathstartindex.length  1) ? _paths.length : _pathstartindex[i + 1];

            
            ierc20token[] memory path = new ierc20token[](pathendindex  _pathstartindex[i]);
            for (uint256 j = _pathstartindex[i]; j < pathendindex; j += 1) {
                path[j  _pathstartindex[i]] = _paths[j];
            }

            
            
            
            ierc20token fromtoken = path[0];
            require(msg.value == 0 || (_amounts[i] <= msg.value && ethertokens[fromtoken]) || !ethertokens[fromtoken]);

            
            
            if (msg.value > 0 && ethertokens[fromtoken]) {
                iethertoken(fromtoken).deposit.value(_amounts[i])();
                convertedvalue += _amounts[i];
            }
            _amounts[i] = convertforinternal(path, _amounts[i], _minreturns[i], _for, 0x0, 0x0, 0x0, 0x0);
        }

        
        require(convertedvalue == msg.value);

        return _amounts;
    }

    
    function convertforinternal(
        ierc20token[] _path, 
        uint256 _amount, 
        uint256 _minreturn, 
        address _for, 
        uint256 _block, 
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s
    )
        private
        validconversionpath(_path)
        returns (uint256)
    {
        if (_v == 0x0 && _r == 0x0 && _s == 0x0) {
            ibancorgaspricelimit gaspricelimit = ibancorgaspricelimit(registry.addressof(contractids.bancor_gas_price_limit));
            gaspricelimit.validategasprice(tx.gasprice);
        }
        else {
            require(verifytrustedsender(_path, _amount, _block, _for, _v, _r, _s));
        }

        
        ierc20token fromtoken = _path[0];

        ierc20token totoken;
        
        (totoken, _amount) = convertbypath(_path, _amount, _minreturn, fromtoken, _for);

        
        
        
        if (ethertokens[totoken])
            iethertoken(totoken).withdrawto(_for, _amount);
        else
            assert(totoken.transfer(_for, _amount));

        return _amount;
    }

    
    function convertbypath(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        ierc20token _fromtoken,
        address _for
    ) private returns (ierc20token, uint256) {
        ismarttoken smarttoken;
        ierc20token totoken;
        ibancorconverter converter;

        
        icontractfeatures features = icontractfeatures(registry.addressof(contractids.contract_features));

        
        uint256 pathlength = _path.length;
        for (uint256 i = 1; i < pathlength; i += 2) {
            smarttoken = ismarttoken(_path[i]);
            totoken = _path[i + 1];
            converter = ibancorconverter(smarttoken.owner());
            checkwhitelist(converter, _for, features);

            
            if (smarttoken != _fromtoken)
                ensureallowance(_fromtoken, converter, _amount);

            
            _amount = converter.change(_fromtoken, totoken, _amount, i == pathlength  2 ? _minreturn : 1);
            _fromtoken = totoken;
        }
        return (totoken, _amount);
    }

    
    function getreturnbypath(ierc20token[] _path, uint256 _amount) public view returns (uint256) {
        ierc20token fromtoken;
        ismarttoken smarttoken; 
        ierc20token totoken;
        ibancorconverter converter;
        uint32 weight;
        uint256 amount;
        uint256 supply;
        ismarttoken prevsmarttoken;
        ibancorformula formula = ibancorformula(registry.getaddress(contractids.bancor_formula));

        amount = _amount;
        fromtoken = _path[0];
        uint256 pathlength = _path.length;

        
        for (uint256 i = 1; i < pathlength; i += 2) {
            smarttoken = ismarttoken(_path[i]);
            totoken = _path[i + 1];
            converter = ibancorconverter(smarttoken.owner());

            if (totoken == smarttoken) { 
                
                supply = smarttoken == prevsmarttoken ? supply : smarttoken.totalsupply();

                
                require(getconnectorpurchaseenabled(converter, fromtoken));

                weight = getconnectorweight(converter, fromtoken);

                
                amount = formula.calculatepurchasereturn(supply, converter.getconnectorbalance(fromtoken), weight, amount);
                amount = safemul(amount, (max_conversion_fee  converter.conversionfee())) / max_conversion_fee;

                
                supply = smarttoken.totalsupply() + amount;
            }
            else if (fromtoken == smarttoken) { 
                
                supply = smarttoken == prevsmarttoken ? supply : smarttoken.totalsupply();

                weight = getconnectorweight(converter, totoken);

                
                amount = formula.calculatesalereturn(supply, converter.getconnectorbalance(totoken), weight, amount);
                amount = safemul(amount, (max_conversion_fee  converter.conversionfee())) / max_conversion_fee;

                
                supply = smarttoken.totalsupply()  amount;
            }
            else { 
                amount = converter.getreturn(fromtoken, totoken, amount);
            }

            prevsmarttoken = smarttoken;
            fromtoken = totoken;
        }
        return amount;
    }

    
    function checkwhitelist(ibancorconverter _converter, address _for, icontractfeatures _features) private view {
        iwhitelist whitelist;

        
        if (!_features.issupported(_converter, featureids.converter_conversion_whitelist))
            return;

        
        whitelist = _converter.conversionwhitelist();
        if (whitelist == address(0))
            return;

        
        require(whitelist.iswhitelisted(_for));
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

    
    function getconnectorweight(ibancorconverter _converter, ierc20token _connector) 
        private
        view
        returns(uint32)
    {
        uint256 virtualbalance;
        uint32 weight;
        bool isvirtualbalanceenabled;
        bool ispurchaseenabled;
        bool isset;
        (virtualbalance, weight, isvirtualbalanceenabled, ispurchaseenabled, isset) = _converter.connectors(_connector);
        return weight;
    }

    
    function getconnectorpurchaseenabled(ibancorconverter _converter, ierc20token _connector) 
        private
        view
        returns(bool)
    {
        uint256 virtualbalance;
        uint32 weight;
        bool isvirtualbalanceenabled;
        bool ispurchaseenabled;
        bool isset;
        (virtualbalance, weight, isvirtualbalanceenabled, ispurchaseenabled, isset) = _converter.connectors(_connector);
        return ispurchaseenabled;
    }

    
    function convertforprioritized(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        uint256 _block,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s)
        public payable returns (uint256)
    {
        _nonce;
        convertforprioritized2(_path, _amount, _minreturn, _for, _block, _v, _r, _s);
    }
}
