pragma solidity 0.4.26;
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


contract bancornetwork is ibancornetwork, tokenholder, contractregistryclient, featureids {
    using safemath for uint256;

    uint256 private constant conversion_fee_resolution = 1000000;
    uint256 private constant affiliate_fee_resolution = 1000000;

    uint256 public maxaffiliatefee = 30000;     
    address public signeraddress = 0x0;         

    mapping (address => bool) public ethertokens;       
    mapping (bytes32 => bool) public conversionhashes;  

    
    constructor(icontractregistry _registry) contractregistryclient(_registry) public {
    }

    
    function setmaxaffiliatefee(uint256 _maxaffiliatefee)
        public
        owneronly
    {
        require(_maxaffiliatefee <= affiliate_fee_resolution);
        maxaffiliatefee = _maxaffiliatefee;
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
            ensuretransferfrom(totoken, this, _for, amount);

        return amount;
    }

    
    function xconvert2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        bytes32 _toblockchain,
        bytes32 _to,
        uint256 _conversionid,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        payable
        returns (uint256)
    {
        return xconvertprioritized3(_path, _amount, _minreturn, _toblockchain, _to, _conversionid, getsignature(0x0, 0x0, 0x0, 0x0, 0x0), _affiliateaccount, _affiliatefee);
    }

    
    function xconvertprioritized3(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        bytes32 _toblockchain,
        bytes32 _to,
        uint256 _conversionid,
        uint256[] memory _signature,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        payable
        returns (uint256)
    {
        
        require(_signature.length == 0 || _signature[0] == _amount);

        
        verifyconversionparams(_path, msg.sender, this, _signature);

        
        require(_path[_path.length  1] == addressof(bnt_token));

        
        handlevalue(_path[0], _amount, true);

        
        uint256 amount = convertbypath(_path, _amount, _minreturn, _affiliateaccount, _affiliatefee);

        
        ibancorx(addressof(bancor_x)).xtransfer(_toblockchain, _to, amount, _conversionid);

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
            bnttoken = addressof(bnt_token);
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
        uint256 amount;
        uint256 fee;
        uint256 supply;
        uint256 balance;
        uint32 ratio;
        ibancorconverter converter;
        ibancorformula formula = ibancorformula(addressof(bancor_formula));

        amount = _amount;

        
        require(_path.length > 2 && _path.length % 2 == 1);

        
        for (uint256 i = 2; i < _path.length; i += 2) {
            ierc20token fromtoken = _path[i  2];
            ierc20token smarttoken = _path[i  1];
            ierc20token totoken = _path[i];

            if (totoken == smarttoken) { 
                
                if (i < 3 || smarttoken != _path[i  3]) {
                    supply = smarttoken.totalsupply();
                    converter = ibancorconverter(ismarttoken(smarttoken).owner());
                }

                
                require(getreservesaleenabled(converter, fromtoken));

                
                balance = converter.getconnectorbalance(fromtoken);
                (, ratio, , , ) = converter.connectors(fromtoken);
                amount = formula.calculatepurchasereturn(supply, balance, ratio, amount);
                fee = amount.mul(converter.conversionfee()).div(conversion_fee_resolution);
                amount = fee;

                
                supply += amount;
            }
            else if (fromtoken == smarttoken) { 
                
                if (i < 3 || smarttoken != _path[i  3]) {
                    supply = smarttoken.totalsupply();
                    converter = ibancorconverter(ismarttoken(smarttoken).owner());
                }

                
                balance = converter.getconnectorbalance(totoken);
                (, ratio, , , ) = converter.connectors(totoken);
                amount = formula.calculatesalereturn(supply, balance, ratio, amount);
                fee = amount.mul(converter.conversionfee()).div(conversion_fee_resolution);
                amount = fee;

                
                supply = amount;
            }
            else { 
                
                if (i < 3 || smarttoken != _path[i  3]) {
                    converter = ibancorconverter(ismarttoken(smarttoken).owner());
                }

                (amount, fee) = getreturn(converter, fromtoken, totoken, amount);
            }
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

    
    function ensuretransferfrom(ierc20token _token, address _from, address _to, uint256 _amount) private {
        
        
        
        
        uint256 prevbalance = _token.balanceof(_to);
        if (_from == address(this))
            inonstandarderc20(_token).transfer(_to, _amount);
        else
            inonstandarderc20(_token).transferfrom(_from, _to, _amount);
        uint256 postbalance = _token.balanceof(_to);
        require(postbalance > prevbalance);
    }

    
    function ensureallowance(ierc20token _token, address _spender, uint256 _value) private {
        
        if (_token.allowance(this, _spender) >= _value)
            return;

        
        if (_token.allowance(this, _spender) != 0)
            inonstandarderc20(_token).approve(_spender, 0);

        
        inonstandarderc20(_token).approve(_spender, _value);
    }

    
    function getreservesaleenabled(ibancorconverter _converter, ierc20token _reserve)
        private
        view
        returns(bool)
    {
        bool issaleenabled;
        (, , , issaleenabled, ) = _converter.connectors(_reserve);
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

        
        icontractfeatures features = icontractfeatures(addressof(contract_features));
        for (uint256 i = 1; i < _path.length; i += 2) {
            ibancorconverter converter = ibancorconverter(ismarttoken(_path[i]).owner());
            if (features.issupported(converter, featureids.converter_conversion_whitelist)) {
                iwhitelist whitelist = converter.conversionwhitelist();
                require(whitelist == address(0) || whitelist.iswhitelisted(_receiver));
            }
        }

        if (_signature.length >= 5) {
            
            verifytrustedsender(_path, _sender, _signature);
        }
        else {
            
            ibancorgaspricelimit gaspricelimit = ibancorgaspricelimit(addressof(bancor_gas_price_limit));
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
        return xconvert2(_path, _amount, _minreturn, _toblockchain, _to, _conversionid, address(0), 0);
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
        return xconvertprioritized3(_path, _amount, _minreturn, _toblockchain, _to, _conversionid, _signature, address(0), 0);
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
        return xconvertprioritized3(_path, _amount, _minreturn, _toblockchain, _to, _conversionid, signature, address(0), 0);
        
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
