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

    uint256 private constant conversion_fee_resolution = 1000000;
    uint256 private constant affiliate_fee_resolution = 1000000;

    uint256 public maxaffiliatefee = 30000;     
    address public signeraddress = 0x0;         
    icontractregistry public registry;          

    mapping (address => bool) public ethertokens;       
    mapping (bytes32 => bool) public conversionhashes;  

    
    constructor(icontractregistry _registry) public validaddress(_registry) {
        registry = _registry;
    }

    
    function setmaxaffiliatefee(uint256 _maxaffiliatefee)
        public
        owneronly
    {
        require(_maxaffiliatefee <= affiliate_fee_resolution);
        maxaffiliatefee = _maxaffiliatefee;
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

    
    function verifytrustedsender(ierc20token[] _path, address _addr, uint256[] memory _signature) private {
        uint256 blocknumber = _signature[1];

        
        require(block.number <= blocknumber);

        
        bytes32 hash = keccak256(abi.encodepacked(blocknumber, tx.gasprice, _addr, msg.sender, _signature[0], _path));

        
        require(!conversionhashes[hash]);

        
        bytes32 prefixedhash = keccak256(abi.encodepacked(, hash));
        require(ecrecover(prefixedhash, uint8(_signature[2]), bytes32(_signature[3]), bytes32(_signature[4])) == signeraddress);

        
        conversionhashes[hash] = true;
    }

    
    function convertfor2(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for, address _affiliateaccount, uint256 _affiliatefee) public payable returns (uint256) {
        return convertforprioritized4(_path, _amount, _minreturn, _for, getsignature(0x0, 0x0, 0x0, 0x0, 0x0), _affiliateaccount, _affiliatefee);
    }

    
    function convertforprioritized4(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        uint256[] memory _signature,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        payable
        returns (uint256)
    {
        
        verifyconversionparams(_path, _for, _for, _signature);

        
        handlevalue(_path[0], _amount, false);

        
        uint256 amount = convertbypath(_path, _amount, _minreturn, _affiliateaccount, _affiliatefee);

        
        
        
        ierc20token totoken = _path[_path.length  1];
        if (ethertokens[totoken])
            iethertoken(totoken).withdrawto(_for, amount);
        else
            ensuretransfer(totoken, _for, amount);

        return amount;
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
        return xconvertprioritized2(_path, _amount, _minreturn, _toblockchain, _to, _conversionid, getsignature(0x0, 0x0, 0x0, 0x0, 0x0));
    }

    
    function xconvertprioritized2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        bytes32 _toblockchain,
        bytes32 _to,
        uint256 _conversionid,
        uint256[] memory _signature
    )
        public
        payable
        returns (uint256)
    {
        
        require(_signature.length == 0 || _signature[0] == _amount);

        
        verifyconversionparams(_path, msg.sender, this, _signature);

        
        require(_path[_path.length  1] == registry.addressof(contractids.bnt_token));

        
        handlevalue(_path[0], _amount, true);

        
        uint256 amount = convertbypath(_path, _amount, _minreturn, address(0), 0);

        
        ibancorx(registry.addressof(contractids.bancor_x)).xtransfer(_toblockchain, _to, amount, _conversionid);

        return amount;
    }

    
    function convertbypath(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _affiliateaccount,
        uint256 _affiliatefee
    ) private returns (uint256) {
        uint256 amount = _amount;
        uint256 lastindex = _path.length  1;

        address bnttoken;
        if (address(_affiliateaccount) == 0) {
            require(_affiliatefee == 0);
            bnttoken = address(0);
        }
        else {
            require(0 < _affiliatefee && _affiliatefee <= maxaffiliatefee);
            bnttoken = registry.addressof(contractids.bnt_token);
        }

        
        for (uint256 i = 2; i <= lastindex; i += 2) {
            ibancorconverter converter = ibancorconverter(ismarttoken(_path[i  1]).owner());

            
            if (_path[i  1] != _path[i  2])
                ensureallowance(_path[i  2], converter, amount);

            
            amount = converter.change(_path[i  2], _path[i], amount, i == lastindex ? _minreturn : 1);

            
            if (address(_path[i]) == bnttoken) {
                uint256 affiliateamount = amount.mul(_affiliatefee).div(affiliate_fee_resolution);
                require(_path[i].transfer(_affiliateaccount, affiliateamount));
                amount = affiliateamount;
                bnttoken = address(0);
            }
        }

        return amount;
    }

    bytes4 private constant get_return_func_selector = bytes4(uint256(keccak256() >> (256  4 * 8)));

    function getreturn(address _dest, address _fromtoken, address _totoken, uint256 _amount) internal view returns (uint256, uint256) {
        uint256[2] memory ret;
        bytes memory data = abi.encodewithselector(get_return_func_selector, _fromtoken, _totoken, _amount);

        assembly {
            let success := staticcall(
                gas,           
                _dest,         
                add(data, 32), 
                mload(data),   
                ret,           
                64             
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        return (ret[0], ret[1]);
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
                fee = amount.mul(converter.conversionfee()).div(conversion_fee_resolution);
                amount = fee;

                
                supply = smarttoken.totalsupply() + amount;
            }
            else if (fromtoken == smarttoken) { 
                
                supply = smarttoken == prevsmarttoken ? supply : smarttoken.totalsupply();

                
                balance = converter.getconnectorbalance(totoken);
                weight = getconnectorweight(converter, totoken);
                amount = formula.calculatesalereturn(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionfee()).div(conversion_fee_resolution);
                amount = fee;

                
                supply = smarttoken.totalsupply()  amount;
            }
            else { 
                (amount, fee) = getreturn(converter, fromtoken, totoken, amount);
            }

            prevsmarttoken = smarttoken;
            fromtoken = totoken;
        }

        return (amount, fee);
    }

    
    function claimandconvertfor2(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for, address _affiliateaccount, uint256 _affiliatefee) public returns (uint256) {
        
        
        
        ierc20token fromtoken = _path[0];
        ensuretransferfrom(fromtoken, msg.sender, this, _amount);
        return convertfor2(_path, _amount, _minreturn, _for, _affiliateaccount, _affiliatefee);
    }

    
    function convert2(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _affiliateaccount, uint256 _affiliatefee) public payable returns (uint256) {
        return convertfor2(_path, _amount, _minreturn, msg.sender, _affiliateaccount, _affiliatefee);
    }

    
    function claimandconvert2(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _affiliateaccount, uint256 _affiliatefee) public returns (uint256) {
        return claimandconvertfor2(_path, _amount, _minreturn, msg.sender, _affiliateaccount, _affiliatefee);
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

    function getsignature(
        uint256 _customval,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (uint256[] memory) {
        if (_v == 0x0 && _r == 0x0 && _s == 0x0)
            return new uint256[](0);
        uint256[] memory signature = new uint256[](5);
        signature[0] = _customval;
        signature[1] = _block;
        signature[2] = uint256(_v);
        signature[3] = uint256(_r);
        signature[4] = uint256(_s);
        return signature;
    }

    function verifyconversionparams(
        ierc20token[] _path,
        address _sender,
        address _receiver,
        uint256[] memory _signature
    )
        private
    {
        
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);

        
        icontractfeatures features = icontractfeatures(registry.addressof(contractids.contract_features));
        for (uint256 i = 1; i < _path.length; i += 2) {
            ibancorconverter converter = ibancorconverter(ismarttoken(_path[i]).owner());
            if (features.issupported(converter, featureids.converter_conversion_whitelist)) {
                iwhitelist whitelist = converter.conversionwhitelist();
                require (whitelist == address(0) || whitelist.iswhitelisted(_receiver));
            }
        }

        if (_signature.length >= 5) {
            
            verifytrustedsender(_path, _sender, _signature);
        }
        else {
            
            ibancorgaspricelimit gaspricelimit = ibancorgaspricelimit(registry.addressof(contractids.bancor_gas_price_limit));
            gaspricelimit.validategasprice(tx.gasprice);
        }
    }

    function handlevalue(ierc20token _token, uint256 _amount, bool _claim) private {
        
        if (msg.value > 0) {
            require(_amount == msg.value && ethertokens[_token]);
            iethertoken(_token).deposit.value(msg.value)();
        }
        
        else if (_claim) {
            ensuretransferfrom(_token, msg.sender, this, _amount);
        }
    }

    
    function convert(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn
    ) public payable returns (uint256)
    {
        return convert2(_path, _amount, _minreturn, address(0), 0);
    }

    
    function claimandconvert(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn
    ) public returns (uint256)
    {
        return claimandconvert2(_path, _amount, _minreturn, address(0), 0);
    }

    
    function convertfor(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for
    ) public payable returns (uint256)
    {
        return convertfor2(_path, _amount, _minreturn, _for, address(0), 0);
    }

    
    function claimandconvertfor(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for
    ) public returns (uint256)
    {
        return claimandconvertfor2(_path, _amount, _minreturn, _for, address(0), 0);
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
        
        uint256[] memory signature = getsignature(_amount, _block, _v, _r, _s);
        return xconvertprioritized2(_path, _amount, _minreturn, _toblockchain, _to, _conversionid, signature);
        
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
        return convertforprioritized4(_path, _amount, _minreturn, _for, getsignature(_customval, _block, _v, _r, _s), address(0), 0);
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
        return convertforprioritized4(_path, _amount, _minreturn, _for, getsignature(_amount, _block, _v, _r, _s), address(0), 0);
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
        return convertforprioritized4(_path, _amount, _minreturn, _for, getsignature(_amount, _block, _v, _r, _s), address(0), 0);
    }
}
