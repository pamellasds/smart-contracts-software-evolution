
pragma solidity 0.6.12;
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


interface ilegacyconverter {
    function change(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, uint256 _minreturn) external returns (uint256);
}


contract bancornetwork is tokenholder, contractregistryclient, reentrancyguard {
    using safemath for uint256;

    uint256 private constant ppm_resolution = 1000000;
    ierc20token private constant eth_reserve_address = ierc20token(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    struct conversionstep {
        iconverter converter;
        iconverteranchor anchor;
        ierc20token sourcetoken;
        ierc20token targettoken;
        address payable beneficiary;
        bool isv28orhigherconverter;
        bool processaffiliatefee;
    }

    uint256 public maxaffiliatefee = 30000;     

    mapping (ierc20token => bool) public ethertokens;   

    
    event conversion(
        iconverteranchor indexed _smarttoken,
        ierc20token indexed _fromtoken,
        ierc20token indexed _totoken,
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
        require(_maxaffiliatefee <= ppm_resolution, );
        maxaffiliatefee = _maxaffiliatefee;
    }

    
    function registerethertoken(iethertoken _token, bool _register)
        public
        owneronly
        validaddress(address(_token))
        notthis(address(_token))
    {
        ethertokens[_token] = _register;
    }

    
    function conversionpath(ierc20token _sourcetoken, ierc20token _targettoken) public view returns (address[] memory) {
        iconversionpathfinder pathfinder = iconversionpathfinder(addressof(conversion_path_finder));
        return pathfinder.findpath(_sourcetoken, _targettoken);
    }

    
    function ratebypath(address[] memory _path, uint256 _amount) public view returns (uint256) {
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
            ierc20token sourcetoken = ierc20token(_path[i  2]);
            address anchor = _path[i  1];
            ierc20token targettoken = ierc20token(_path[i]);

            converter = iconverter(payable(iconverteranchor(anchor).owner()));

            
            sourcetoken = getconvertertokenaddress(converter, sourcetoken);
            targettoken = getconvertertokenaddress(converter, targettoken);

            if (address(targettoken) == anchor) { 
                
                if (i < 3 || anchor != _path[i  3])
                    supply = idstoken(anchor).totalsupply();

                
                balance = converter.getconnectorbalance(sourcetoken);
                (, weight, , , ) = converter.connectors(sourcetoken);
                amount = formula.purchasetargetamount(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionfee()).div(ppm_resolution);
                amount = fee;

                
                supply = supply.add(amount);
            }
            else if (address(sourcetoken) == anchor) { 
                
                if (i < 3 || anchor != _path[i  3])
                    supply = idstoken(anchor).totalsupply();

                
                balance = converter.getconnectorbalance(targettoken);
                (, weight, , , ) = converter.connectors(targettoken);
                amount = formula.saletargetamount(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionfee()).div(ppm_resolution);
                amount = fee;

                
                supply = supply.sub(amount);
            }
            else { 
                (amount, fee) = getreturn(converter, sourcetoken, targettoken, amount);
            }
        }

        return amount;
    }

    
    function convertbypath(
        address[] memory _path,
        uint256 _amount,
        uint256 _minreturn,
        address payable _beneficiary,
        address _affiliateaccount,
        uint256 _affiliatefee)
        public
        payable
        protected
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        
        require(_path.length > 2 && _path.length % 2 == 1, );

        
        handlesourcetoken(ierc20token(_path[0]), iconverteranchor(_path[1]), _amount);

        
        bool affiliatefeeenabled = false;
        if (address(_affiliateaccount) == address(0)) {
            require(_affiliatefee == 0, );
        }
        else {
            require(0 < _affiliatefee && _affiliatefee <= maxaffiliatefee, );
            affiliatefeeenabled = true;
        }

        
        address payable beneficiary = msg.sender;
        if (_beneficiary != address(0))
            beneficiary = _beneficiary;

        
        conversionstep[] memory data = createconversiondata(_path, beneficiary, affiliatefeeenabled);
        uint256 amount = doconversion(data, _amount, _minreturn, _affiliateaccount, _affiliatefee);

        
        handletargettoken(data, amount, beneficiary);

        return amount;
    }

    
    function xconvert(
        address[] memory _path,
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
        address[] memory _path,
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
        ierc20token targettoken = ierc20token(_path[_path.length  1]);
        ibancorx bancorx = ibancorx(addressof(bancor_x));

        
        require(targettoken == ierc20token(addressof(bnt_token)), );

        
        uint256 amount = convertbypath(_path, _amount, _minreturn, payable(address(this)), _affiliateaccount, _affiliatefee);

        
        ensureallowance(targettoken, address(bancorx), amount);

        
        bancorx.xtransfer(_targetblockchain, _targetaccount, amount, _conversionid);

        return amount;
    }

    
    function completexconversion(address[] memory _path, ibancorx _bancorx, uint256 _conversionid, uint256 _minreturn, address payable _beneficiary)
        public returns (uint256)
    {
        
        require(ierc20token(_path[0]) == _bancorx.token(), );

        
        uint256 amount = _bancorx.getxtransferamount(_conversionid, msg.sender);

        
        return convertbypath(_path, amount, _minreturn, _beneficiary, address(0), 0);
    }

    
    function doconversion(
        conversionstep[] memory _data,
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
                    safetransfer(stepdata.sourcetoken, address(stepdata.converter), fromamount);
            }
            
            
            else if (stepdata.sourcetoken != idstoken(address(stepdata.anchor))) {
                
                ensureallowance(stepdata.sourcetoken, address(stepdata.converter), fromamount);
            }

            
            if (!stepdata.isv28orhigherconverter)
                toamount = ilegacyconverter(address(stepdata.converter)).change(stepdata.sourcetoken, stepdata.targettoken, fromamount, 1);
            else if (ethertokens[stepdata.sourcetoken])
                toamount = stepdata.converter.convert{ value: msg.value }(stepdata.sourcetoken, stepdata.targettoken, fromamount, msg.sender, stepdata.beneficiary);
            else
                toamount = stepdata.converter.convert(stepdata.sourcetoken, stepdata.targettoken, fromamount, msg.sender, stepdata.beneficiary);

            
            if (stepdata.processaffiliatefee) {
                uint256 affiliateamount = toamount.mul(_affiliatefee).div(ppm_resolution);
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
        iconverter firstconverter = iconverter(payable(_anchor.owner()));
        bool isnewerconverter = isv28orhigherconverter(firstconverter);

        
        if (msg.value > 0) {
            
            require(msg.value == _amount, );

            
            
            
            if (!isnewerconverter)
                iethertoken(address(getconverterethertokenaddress(firstconverter))).deposit{ value: msg.value }();
        }
        
        else if (ethertokens[_sourcetoken]) {
            
            
            safetransferfrom(_sourcetoken, msg.sender, address(this), _amount);

            
            if (isnewerconverter)
                iethertoken(address(_sourcetoken)).withdraw(_amount);
        }
        
        else {
            
            
            if (isnewerconverter)
                safetransferfrom(_sourcetoken, msg.sender, address(firstconverter), _amount);
            else
                safetransferfrom(_sourcetoken, msg.sender, address(this), _amount);
        }
    }

    
    function handletargettoken(conversionstep[] memory _data, uint256 _amount, address payable _beneficiary) private {
        conversionstep memory stepdata = _data[_data.length  1];

        
        if (stepdata.beneficiary != address(this))
            return;

        ierc20token targettoken = stepdata.targettoken;

        
        if (ethertokens[targettoken]) {
            
            assert(!stepdata.isv28orhigherconverter);

            
            iethertoken(address(targettoken)).withdrawto(_beneficiary, _amount);
        }
        
        else {
            safetransfer(targettoken, _beneficiary, _amount);
        }
    }

    
    function createconversiondata(address[] memory _conversionpath, address payable _beneficiary, bool _affiliatefeeenabled) private view returns (conversionstep[] memory) {
        conversionstep[] memory data = new conversionstep[](_conversionpath.length / 2);

        bool affiliatefeeprocessed = false;
        ierc20token bnttoken = ierc20token(addressof(bnt_token));
        
        uint256 i;
        for (i = 0; i < _conversionpath.length  1; i += 2) {
            iconverteranchor anchor = iconverteranchor(_conversionpath[i + 1]);
            iconverter converter = iconverter(payable(anchor.owner()));
            ierc20token targettoken = ierc20token(_conversionpath[i + 2]);

            
            bool processaffiliatefee = _affiliatefeeenabled && !affiliatefeeprocessed && targettoken == bnttoken;
            if (processaffiliatefee)
                affiliatefeeprocessed = true;

            data[i / 2] = conversionstep({
                
                anchor: anchor,

                
                converter: converter,

                
                sourcetoken: ierc20token(_conversionpath[i]),
                targettoken: targettoken,

                
                beneficiary: address(0),

                
                isv28orhigherconverter: isv28orhigherconverter(converter),
                processaffiliatefee: processaffiliatefee
            });
        }

        
        
        conversionstep memory stepdata = data[0];
        if (ethertokens[stepdata.sourcetoken]) {
            
            if (stepdata.isv28orhigherconverter)
                stepdata.sourcetoken = eth_reserve_address;
            
            else
                stepdata.sourcetoken = getconverterethertokenaddress(stepdata.converter);
        }

        
        stepdata = data[data.length  1];
        if (ethertokens[stepdata.targettoken]) {
            
            if (stepdata.isv28orhigherconverter)
                stepdata.targettoken = eth_reserve_address;
            
            else
                stepdata.targettoken = getconverterethertokenaddress(stepdata.converter);
        }

        
        for (i = 0; i < data.length; i++) {
            stepdata = data[i];

            
            if (stepdata.isv28orhigherconverter) {
                
                if (stepdata.processaffiliatefee)
                    stepdata.beneficiary = payable(address(this));
                
                else if (i == data.length  1)
                    stepdata.beneficiary = _beneficiary;
                
                else if (data[i + 1].isv28orhigherconverter)
                    stepdata.beneficiary = address(data[i + 1].converter);
                
                else
                    stepdata.beneficiary = payable(address(this));
            }
            else {
                
                stepdata.beneficiary = payable(address(this));
            }
        }

        return data;
    }

    
    function ensureallowance(ierc20token _token, address _spender, uint256 _value) private {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _value) {
            if (allowance > 0)
                safeapprove(_token, _spender, 0);
            safeapprove(_token, _spender, _value);
        }
    }

    
    function getconverterethertokenaddress(iconverter _converter) private view returns (ierc20token) {
        uint256 reservecount = _converter.connectortokencount();
        for (uint256 i = 0; i < reservecount; i++) {
            ierc20token reservetokenaddress = _converter.connectortokens(i);
            if (ethertokens[reservetokenaddress])
                return reservetokenaddress;
        }

        return eth_reserve_address;
    }

    
    
    function getconvertertokenaddress(iconverter _converter, ierc20token _token) private view returns (ierc20token) {
        if (!ethertokens[_token])
            return _token;

        if (isv28orhigherconverter(_converter))
            return eth_reserve_address;

        return getconverterethertokenaddress(_converter);
    }

    bytes4 private constant get_return_func_selector = bytes4(keccak256());

    
    function getreturn(iconverter _dest, ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) internal view returns (uint256, uint256) {
        bytes memory data = abi.encodewithselector(get_return_func_selector, _sourcetoken, _targettoken, _amount);
        (bool success, bytes memory returndata) = address(_dest).staticcall(data);

        if (success) {
            if (returndata.length == 64) {
                return abi.decode(returndata, (uint256, uint256));
            }

            if (returndata.length == 32) {
                return (abi.decode(returndata, (uint256)), 0);
            }
        }

        return (0, 0);
    }

    bytes4 private constant is_v28_or_higher_func_selector = bytes4(keccak256());

    
    
    function isv28orhigherconverter(iconverter _converter) internal view returns (bool) {
        bytes memory data = abi.encodewithselector(is_v28_or_higher_func_selector);
        (bool success, bytes memory returndata) = address(_converter).staticcall{ gas: 4000 }(data);

        if (success && returndata.length == 32) {
            return abi.decode(returndata, (bool));
        }

        return false;
    }

    
    function getreturnbypath(address[] memory _path, uint256 _amount) public view returns (uint256, uint256) {
        return (ratebypath(_path, _amount), 0);
    }

    
    function convert(address[] memory _path, uint256 _amount, uint256 _minreturn) public payable returns (uint256) {
        return convertbypath(_path, _amount, _minreturn, address(0), address(0), 0);
    }

    
    function convert2(
        address[] memory _path,
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

    
    function convertfor(address[] memory _path, uint256 _amount, uint256 _minreturn, address payable _beneficiary) public payable returns (uint256) {
        return convertbypath(_path, _amount, _minreturn, _beneficiary, address(0), 0);
    }

    
    function convertfor2(
        address[] memory _path,
        uint256 _amount,
        uint256 _minreturn,
        address payable _beneficiary,
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

    
    function claimandconvert(address[] memory _path, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return convertbypath(_path, _amount, _minreturn, address(0), address(0), 0);
    }

    
    function claimandconvert2(
        address[] memory _path,
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

    
    function claimandconvertfor(address[] memory _path, uint256 _amount, uint256 _minreturn, address payable _beneficiary) public returns (uint256) {
        return convertbypath(_path, _amount, _minreturn, _beneficiary, address(0), 0);
    }

    
    function claimandconvertfor2(
        address[] memory _path,
        uint256 _amount,
        uint256 _minreturn,
        address payable _beneficiary,
        address _affiliateaccount,
        uint256 _affiliatefee
    )
        public
        returns (uint256)
    {
        return convertbypath(_path, _amount, _minreturn, _beneficiary, _affiliateaccount, _affiliatefee);
    }
}
