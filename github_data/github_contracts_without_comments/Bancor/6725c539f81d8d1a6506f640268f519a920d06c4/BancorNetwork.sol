pragma solidity ^0.4.24;
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
import ;
import ;
import ;
import ;


contract bancornetwork is ibancornetwork, tokenholder, contractids, featureids {
    using safemath for uint256;

    
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

    
    function verifytrustedsender(ierc20token[] _path, uint256 _customval, uint256 _block, address _addr, uint8 _v, bytes32 _r, bytes32 _s) private returns(bool) {
        bytes32 hash = keccak256(_block, tx.gasprice, _addr, msg.sender, _customval, _path);

        
        
        
        require(!conversionhashes[hash] && block.number <= _block);

        
        
        bytes32 prefixedhash = keccak256(, hash);
        bool verified = ecrecover(prefixedhash, _v, _r, _s) == signeraddress;

        
        
        if (verified)
            conversionhashes[hash] = true;
        return verified;
    }

    
    function validatexconversion(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) 
        private 
        validconversionpath(_path)    
    {
        
        ierc20token fromtoken = _path[0];
        require(msg.value == 0 || (_amount == msg.value && ethertokens[fromtoken]));

        
        require(_path[_path.length  1] == registry.addressof(contractids.bnt_token));

        
        
        if (msg.value > 0) {
            iethertoken(fromtoken).deposit.value(msg.value)();
        } else {
            ensuretransferfrom(fromtoken, msg.sender, this, _amount);
        }

        
        if (_v == 0x0 && _r == 0x0 && _s == 0x0) {
            ibancorgaspricelimit gaspricelimit = ibancorgaspricelimit(registry.addressof(contractids.bancor_gas_price_limit));
            gaspricelimit.validategasprice(tx.gasprice);
        } else {
            require(verifytrustedsender(_path, _amount, _block, msg.sender, _v, _r, _s));
        }
    }

    
    function convertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for) public payable returns (uint256) {
        return convertforprioritized3(_path, _amount, _minreturn, _for, _amount, 0x0, 0x0, 0x0, 0x0);
    }

    
    function convertforprioritized3(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        uint256 _customval,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        returns (uint256)
    {
        
        ierc20token fromtoken = _path[0];
        require(msg.value == 0 || (_amount == msg.value && ethertokens[fromtoken]));

        
        
        if (msg.value > 0)
            iethertoken(fromtoken).deposit.value(msg.value)();

        return convertforinternal(_path, _amount, _minreturn, _for, _customval, _block, _v, _r, _s);
    }

    
    function xconvert(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        bytes32 _toblockchain,
        bytes32 _to,
        uint256 _conversionid
    )
        public
        payable
        returns (uint256)
    {
        return xconvertprioritized(_path, _amount, _minreturn, _toblockchain, _to, _conversionid, 0x0, 0x0, 0x0, 0x0);
    }

    
    function xconvertprioritized(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        bytes32 _toblockchain,
        bytes32 _to,
        uint256 _conversionid,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        returns (uint256)
    {
        
        validatexconversion(_path, _amount, _block, _v, _r, _s);

        
        (, uint256 retamount) = convertbypath(_path, _amount, _minreturn, _path[0], this);

        
        ibancorx(registry.addressof(contractids.bancor_x)).xtransfer(_toblockchain, _to, retamount, _conversionid);

        return retamount;
    }

    
    function convertforinternal(
        ierc20token[] _path, 
        uint256 _amount, 
        uint256 _minreturn, 
        address _for, 
        uint256 _customval,
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
            require(verifytrustedsender(_path, _customval, _block, _for, _v, _r, _s));
        }

        
        ierc20token fromtoken = _path[0];

        ierc20token totoken;
        
        (totoken, _amount) = convertbypath(_path, _amount, _minreturn, fromtoken, _for);

        
        
        
        if (ethertokens[totoken])
            iethertoken(totoken).withdrawto(_for, _amount);
        else
            ensuretransfer(totoken, _for, _amount);

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

    
    function getreturnbypath(ierc20token[] _path, uint256 _amount) public view returns (uint256, uint256) {
        ierc20token fromtoken;
        ismarttoken smarttoken; 
        ierc20token totoken;
        ibancorconverter converter;
        uint256 amount;
        uint256 fee;
        uint256 supply;
        uint256 balance;
        uint32 weight;
        ismarttoken prevsmarttoken;
        ibancorformula formula = ibancorformula(registry.getaddress(contractids.bancor_formula));

        amount = _amount;
        fromtoken = _path[0];

        
        for (uint256 i = 1; i < _path.length; i += 2) {
            smarttoken = ismarttoken(_path[i]);
            totoken = _path[i + 1];
            converter = ibancorconverter(smarttoken.owner());

            if (totoken == smarttoken) { 
                
                supply = smarttoken == prevsmarttoken ? supply : smarttoken.totalsupply();

                
                require(getconnectorsaleenabled(converter, fromtoken));

                
                balance = converter.getconnectorbalance(fromtoken);
                weight = getconnectorweight(converter, fromtoken);
                amount = formula.calculatepurchasereturn(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionfee()).div(max_conversion_fee);
                amount = fee;

                
                supply = smarttoken.totalsupply() + amount;
            }
            else if (fromtoken == smarttoken) { 
                
                supply = smarttoken == prevsmarttoken ? supply : smarttoken.totalsupply();

                
                balance = converter.getconnectorbalance(totoken);
                weight = getconnectorweight(converter, totoken);
                amount = formula.calculatesalereturn(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionfee()).div(max_conversion_fee);
                amount = fee;

                
                supply = smarttoken.totalsupply()  amount;
            }
            else { 
                (amount, fee) = converter.getreturn(fromtoken, totoken, amount);
            }

            prevsmarttoken = smarttoken;
            fromtoken = totoken;
        }

        return (amount, fee);
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
        ensuretransferfrom(fromtoken, msg.sender, this, _amount);
        return convertfor(_path, _amount, _minreturn, _for);
    }

    
    function convert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public payable returns (uint256) {
        return convertfor(_path, _amount, _minreturn, msg.sender);
    }

    
    function claimandconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return claimandconvertfor(_path, _amount, _minreturn, msg.sender);
    }

    
    function ensuretransfer(ierc20token _token, address _to, uint256 _amount) private {
        iaddresslist addresslist = iaddresslist(registry.addressof(contractids.non_standard_token_registry));

        if (addresslist.listedaddresses(_token)) {
            uint256 prevbalance = _token.balanceof(_to);
            
            inonstandarderc20(_token).transfer(_to, _amount);
            uint256 postbalance = _token.balanceof(_to);
            assert(postbalance > prevbalance);
        } else {
            
            assert(_token.transfer(_to, _amount));
        }
    }

    
    function ensuretransferfrom(ierc20token _token, address _from, address _to, uint256 _amount) private {
        iaddresslist addresslist = iaddresslist(registry.addressof(contractids.non_standard_token_registry));

        if (addresslist.listedaddresses(_token)) {
            uint256 prevbalance = _token.balanceof(_to);
            
            inonstandarderc20(_token).transferfrom(_from, _to, _amount);
            uint256 postbalance = _token.balanceof(_to);
            assert(postbalance > prevbalance);
        } else {
            
            assert(_token.transferfrom(_from, _to, _amount));
        }
    }

    
    function ensureallowance(ierc20token _token, address _spender, uint256 _value) private {
        
        if (_token.allowance(this, _spender) >= _value)
            return;

        
        if (_token.allowance(this, _spender) != 0)
            inonstandarderc20(_token).approve(_spender, 0);

        
        inonstandarderc20(_token).approve(_spender, _value);
    }

    
    function getconnectorweight(ibancorconverter _converter, ierc20token _connector) 
        private
        view
        returns(uint32)
    {
        uint256 virtualbalance;
        uint32 weight;
        bool isvirtualbalanceenabled;
        bool issaleenabled;
        bool isset;
        (virtualbalance, weight, isvirtualbalanceenabled, issaleenabled, isset) = _converter.connectors(_connector);
        return weight;
    }

    
    function getconnectorsaleenabled(ibancorconverter _converter, ierc20token _connector) 
        private
        view
        returns(bool)
    {
        uint256 virtualbalance;
        uint32 weight;
        bool isvirtualbalanceenabled;
        bool issaleenabled;
        bool isset;
        (virtualbalance, weight, isvirtualbalanceenabled, issaleenabled, isset) = _converter.connectors(_connector);
        return issaleenabled;
    }

    
    function convertforprioritized2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        returns (uint256)
    {
        return convertforprioritized3(_path, _amount, _minreturn, _for, _amount, _block, _v, _r, _s);
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
        return convertforprioritized3(_path, _amount, _minreturn, _for, _amount, _block, _v, _r, _s);
    }
}
