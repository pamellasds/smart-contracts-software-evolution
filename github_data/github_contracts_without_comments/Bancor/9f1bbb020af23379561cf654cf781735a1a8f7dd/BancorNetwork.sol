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


contract ilegacyconverter {
    function change(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
}


contract bancornetwork is ibancornetwork, tokenholder, contractregistryclient, reentrancyguard {
    using safemath for uint256;

    uint256 private constant conversion_fee_resolution = 1000000;
    uint256 private constant affiliate_fee_resolution = 1000000;
    address private constant eth_reserve_address = 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;

    struct conversionstep {
        iconverter converter;
        iconverteranchor anchor;
        ierc20token sourcetoken;
        ierc20token targettoken;
        address beneficiary;
        bool isv28orhigherconverter;
        bool processaffiliatefee;
    }

    uint256 public maxaffiliatefee = 30000;     

    mapping (address => bool) public ethertokens;       

    
    event conversion(
        address indexed _smarttoken,
        address indexed _fromtoken,
        address indexed _totoken,
        uint256 _fromamount,
        uint256 _toamount,
        address _trader
    );

    
    constructor(icontractregistry _registry) contractregistryclient(_registry) public {
        ethertokens[eth_reserve_address] = true;
    }

    
    function setmaxaffiliatefee(uint256 _maxaffiliatefee)
        public
        owneronly
    {
        require(_maxaffiliatefee <= affiliate_fee_resolution, );
        maxaffiliatefee = _maxaffiliatefee;
    }

    
    function registerethertoken(iethertoken _token, bool _register)
        public
        owneronly
        validaddress(_token)
        notthis(_token)
    {
        ethertokens[_token] = _register;
    }

    
    function conversionpath(ierc20token _sourcetoken, ierc20token _targettoken) public view returns (address[]) {
        iconversionpathfinder pathfinder = iconversionpathfinder(addressof(conversion_path_finder));
        return pathfinder.findpath(_sourcetoken, _targettoken);
    }

    
    function ratebypath(ierc20token[] _path, uint256 _amount) public view returns (uint256) {
        uint256 amount;
        uint256 fee;
        uint256 supply;
        uint256 balance;
        uint32 weight;
        iconverter converter;
        ibancorformula formula = ibancorformula(addressof(bancor_formula));

        amount = _amount;

        
        require(_path.length > 2 && _path.length % 2 == 1, );

        
        for (uint256 i = 2; i < _path.length; i += 2) {
            ierc20token sourcetoken = _path[i  2];
            ierc20token anchor = _path[i  1];
            ierc20token targettoken = _path[i];

            converter = iconverter(iconverteranchor(anchor).owner());

            
            if (ethertokens[sourcetoken]) {
                if (isv28orhigherconverter(converter))
                    sourcetoken = ierc20token(eth_reserve_address);
                else
                    sourcetoken = ierc20token(getconverterethertokenaddress(converter));
            }
            if (ethertokens[targettoken]) {
                if (isv28orhigherconverter(converter))
                    targettoken = ierc20token(eth_reserve_address);
                else
                    targettoken = ierc20token(getconverterethertokenaddress(converter));
            }

            if (targettoken == anchor) { 
                
                if (i < 3 || anchor != _path[i  3])
                    supply = ismarttoken(anchor).totalsupply();

                
                balance = converter.getconnectorbalance(sourcetoken);
                (, weight, , , ) = converter.connectors(sourcetoken);
                amount = formula.purchaserate(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionfee()).div(conversion_fee_resolution);
                amount = fee;

                
                supply = supply.add(amount);
            }
            else if (sourcetoken == anchor) { 
                
                if (i < 3 || anchor != _path[i  3])
                    supply = ismarttoken(anchor).totalsupply();

                
                balance = converter.getconnectorbalance(targettoken);
                (, weight, , , ) = converter.connectors(targettoken);
                amount = formula.salerate(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionfee()).div(conversion_fee_resolution);
                amount = fee;

                
                supply = supply.sub(amount);
            }
            else { 
                (amount, fee) = getreturn(converter, sourcetoken, targettoken, amount);
            }
        }

        return amount;
    }

    
    function convertbypath(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _beneficiary, address _affiliateaccount, uint256 _affiliatefee)
        public
        payable
        protected
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        
        require(_path.length > 2 && _path.length % 2 == 1, );

        
        handlesourcetoken(_path[0], iconverteranchor(_path[1]), _amount);

        
        bool affiliatefeeenabled = false;
        if (address(_affiliateaccount) == 0) {
            require(_affiliatefee == 0, );
        }
        else {
            require(0 < _affiliatefee && _affiliatefee <= maxaffiliatefee, );
            affiliatefeeenabled = true;
        }

        
        address beneficiary = msg.sender;
        if (_beneficiary != address(0))
            beneficiary = _beneficiary;

        
        conversionstep[] memory data = createconversiondata(_path, beneficiary, affiliatefeeenabled);
        uint256 amount = doconversion(data, _amount, _minreturn, _affiliateaccount, _affiliatefee);

        
        handletargettoken(data, amount, beneficiary);

        return amount;
    }

    
    function xconvert(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        bytes32 _targetblockchain,
        bytes32 _targetaccount,
        uint256 _conversionid
    )
        public
        payable
        returns (uint256)
    {
        return xconvert2(_path, _amount, _minreturn, _targetblockchain, _targetaccount, _conversionid, address(0), 0);
    }

    
    function xconvert2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        bytes32 _targetblockchain,
        bytes32 _targetaccount,
        uint256 _conversionid,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        payable
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        ierc20token targettoken = _path[_path.length  1];
        ibancorx bancorx = ibancorx(addressof(bancor_x));

        
        require(targettoken == addressof(bnt_token), );

        
        uint256 amount = convertbypath(_path, _amount, _minreturn, this, _affiliateaccount, _affiliatefee);

        
        ensureallowance(targettoken, bancorx, amount);

        
        bancorx.xtransfer(_targetblockchain, _targetaccount, amount, _conversionid);

        return amount;
    }

    
    function completexconversion(ierc20token[] _path, ibancorx _bancorx, uint256 _conversionid, uint256 _minreturn, address _beneficiary)
        public returns (uint256)
    {
        
        require(_path[0] == _bancorx.token(), );

        
        uint256 amount = _bancorx.getxtransferamount(_conversionid, msg.sender);

        
        return convertbypath(_path, amount, _minreturn, _beneficiary, address(0), 0);
    }

    
    function doconversion(
        conversionstep[] _data,
        uint256 _amount,
        uint256 _minreturn,
        address _affiliateaccount,
        uint256 _affiliatefee
    ) private returns (uint256) {
        uint256 toamount;
        uint256 fromamount = _amount;

        
        for (uint256 i = 0; i < _data.length; i++) {
            conversionstep memory stepdata = _data[i];

            
            if (stepdata.isv28orhigherconverter) {
                
                
                if (i != 0 && _data[i  1].beneficiary == address(this) && !ethertokens[stepdata.sourcetoken])
                    safetransfer(stepdata.sourcetoken, stepdata.converter, fromamount);
            }
            
            
            else if (stepdata.sourcetoken != ismarttoken(stepdata.anchor)) {
                
                ensureallowance(stepdata.sourcetoken, stepdata.converter, fromamount);
            }

            
            if (!stepdata.isv28orhigherconverter)
                toamount = ilegacyconverter(stepdata.converter).change(stepdata.sourcetoken, stepdata.targettoken, fromamount, 1);
            else if (ethertokens[stepdata.sourcetoken])
                toamount = stepdata.converter.convert.value(msg.value)(stepdata.sourcetoken, stepdata.targettoken, fromamount, msg.sender, stepdata.beneficiary);
            else
                toamount = stepdata.converter.convert(stepdata.sourcetoken, stepdata.targettoken, fromamount, msg.sender, stepdata.beneficiary);

            
            if (stepdata.processaffiliatefee) {
                uint256 affiliateamount = toamount.mul(_affiliatefee).div(affiliate_fee_resolution);
                require(stepdata.targettoken.transfer(_affiliateaccount, affiliateamount), );
                toamount = affiliateamount;
            }

            emit conversion(stepdata.anchor, stepdata.sourcetoken, stepdata.targettoken, fromamount, toamount, msg.sender);
            fromamount = toamount;
        }

        
        require(toamount >= _minreturn, );

        return toamount;
    }

    
    function handlesourcetoken(ierc20token _sourcetoken, iconverteranchor _anchor, uint256 _amount) private {
        iconverter firstconverter = iconverter(_anchor.owner());
        bool isnewerconverter = isv28orhigherconverter(firstconverter);

        
        if (msg.value > 0) {
            
            require(msg.value == _amount, );

            
            
            
            if (!isnewerconverter)
                iethertoken(getconverterethertokenaddress(firstconverter)).deposit.value(msg.value)();
        }
        
        else if (ethertokens[_sourcetoken]) {
            
            
            safetransferfrom(_sourcetoken, msg.sender, this, _amount);

            
            if (isnewerconverter)
                iethertoken(_sourcetoken).withdraw(_amount);
        }
        
        else {
            
            
            if (isnewerconverter)
                safetransferfrom(_sourcetoken, msg.sender, firstconverter, _amount);
            else
                safetransferfrom(_sourcetoken, msg.sender, this, _amount);
        }
    }

    
    function handletargettoken(conversionstep[] _data, uint256 _amount, address _beneficiary) private {
        conversionstep memory stepdata = _data[_data.length  1];

        
        if (stepdata.beneficiary != address(this))
            return;

        ierc20token targettoken = stepdata.targettoken;

        
        if (ethertokens[targettoken]) {
            
            assert(!stepdata.isv28orhigherconverter);

            
            iethertoken(targettoken).withdrawto(_beneficiary, _amount);
        }
        
        else {
            safetransfer(targettoken, _beneficiary, _amount);
        }
    }

    
    function createconversiondata(ierc20token[] _conversionpath, address _beneficiary, bool _affiliatefeeenabled) private view returns (conversionstep[]) {
        conversionstep[] memory data = new conversionstep[](_conversionpath.length / 2);

        bool affiliatefeeprocessed = false;
        address bnttoken = addressof(bnt_token);
        
        uint256 i;
        for (i = 0; i < _conversionpath.length  1; i += 2) {
            iconverteranchor anchor = iconverteranchor(_conversionpath[i + 1]);
            iconverter converter = iconverter(anchor.owner());
            ierc20token targettoken = _conversionpath[i + 2];

            
            bool processaffiliatefee = _affiliatefeeenabled && !affiliatefeeprocessed && targettoken == bnttoken;
            if (processaffiliatefee)
                affiliatefeeprocessed = true;

            data[i / 2] = conversionstep({
                
                anchor: anchor,

                
                converter: converter,

                
                sourcetoken: _conversionpath[i],
                targettoken: targettoken,

                
                beneficiary: address(0),

                
                isv28orhigherconverter: isv28orhigherconverter(converter),
                processaffiliatefee: processaffiliatefee
            });
        }

        
        
        conversionstep memory stepdata = data[0];
        if (ethertokens[stepdata.sourcetoken]) {
            
            if (stepdata.isv28orhigherconverter)
                stepdata.sourcetoken = ierc20token(eth_reserve_address);
            
            else
                stepdata.sourcetoken = ierc20token(getconverterethertokenaddress(stepdata.converter));
        }

        
        stepdata = data[data.length  1];
        if (ethertokens[stepdata.targettoken]) {
            
            if (stepdata.isv28orhigherconverter)
                stepdata.targettoken = ierc20token(eth_reserve_address);
            
            else
                stepdata.targettoken = ierc20token(getconverterethertokenaddress(stepdata.converter));
        }

        
        for (i = 0; i < data.length; i++) {
            stepdata = data[i];

            
            if (stepdata.isv28orhigherconverter) {
                
                if (stepdata.processaffiliatefee)
                    stepdata.beneficiary = this;
                
                else if (i == data.length  1)
                    stepdata.beneficiary = _beneficiary;
                
                else if (data[i + 1].isv28orhigherconverter)
                    stepdata.beneficiary = data[i + 1].converter;
                
                else
                    stepdata.beneficiary = this;
            }
            else {
                
                stepdata.beneficiary = this;
            }
        }

        return data;
    }

    
    function ensureallowance(ierc20token _token, address _spender, uint256 _value) private {
        uint256 allowance = _token.allowance(this, _spender);
        if (allowance < _value) {
            if (allowance > 0)
                safeapprove(_token, _spender, 0);
            safeapprove(_token, _spender, _value);
        }
    }

    
    function getconverterethertokenaddress(iconverter _converter) private view returns (address) {
        uint256 reservecount = _converter.connectortokencount();
        for (uint256 i = 0; i < reservecount; i++) {
            address reservetokenaddress = _converter.connectortokens(i);
            if (ethertokens[reservetokenaddress])
                return reservetokenaddress;
        }

        return eth_reserve_address;
    }

    bytes4 private constant get_return_func_selector = bytes4(keccak256());

    
    function getreturn(address _dest, address _sourcetoken, address _targettoken, uint256 _amount) internal view returns (uint256, uint256) {
        uint256[2] memory ret;
        bytes memory data = abi.encodewithselector(get_return_func_selector, _sourcetoken, _targettoken, _amount);

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

    bytes4 private constant is_v28_or_higher_func_selector = bytes4(keccak256());

    
    
    function isv28orhigherconverter(iconverter _converter) internal view returns (bool) {
        bool success;
        uint256[1] memory ret;
        bytes memory data = abi.encodewithselector(is_v28_or_higher_func_selector);

        assembly {
            success := staticcall(
                50000,         
                _converter,    
                add(data, 32), 
                mload(data),   
                ret,           
                32             
            )
        }

        return success && ret[0] != 0;
    }

    
    function getreturnbypath(ierc20token[] _path, uint256 _amount) public view returns (uint256, uint256) {
        return (ratebypath(_path, _amount), 0);
    }

    
    function convert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public payable returns (uint256) {
        return convertbypath(_path, _amount, _minreturn, address(0), address(0), 0);
    }

    
    function convert2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        payable
        returns (uint256)
    {
        return convertbypath(_path, _amount, _minreturn, address(0), _affiliateaccount, _affiliatefee);
    }

    
    function convertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _beneficiary) public payable returns (uint256) {
        return convertbypath(_path, _amount, _minreturn, _beneficiary, address(0), 0);
    }

    
    function convertfor2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _beneficiary,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        payable
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        return convertbypath(_path, _amount, _minreturn, _beneficiary, _affiliateaccount, _affiliatefee);
    }

    
    function claimandconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return convertbypath(_path, _amount, _minreturn, address(0), address(0), 0);
    }

    
    function claimandconvert2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        returns (uint256)
    {
        return convertbypath(_path, _amount, _minreturn, address(0), _affiliateaccount, _affiliatefee);
    }

    
    function claimandconvertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _beneficiary) public returns (uint256) {
        return convertbypath(_path, _amount, _minreturn, _beneficiary, address(0), 0);
    }

    
    function claimandconvertfor2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _beneficiary,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        returns (uint256)
    {
        return convertbypath(_path, _amount, _minreturn, _beneficiary, _affiliateaccount, _affiliatefee);
    }
}
