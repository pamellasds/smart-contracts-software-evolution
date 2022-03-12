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


contract bancorconverter is ibancorconverter, smarttokencontroller, managed, contractids, featureids {
    uint32 private constant max_weight = 1000000;
    uint64 private constant max_conversion_fee = 1000000;

    struct connector {
        uint256 virtualbalance;         
        uint32 weight;                  
        bool isvirtualbalanceenabled;   
        bool ispurchaseenabled;         
        bool isset;                     
    }

    string public version = ;
    string public convertertype = ;

    icontractregistry public registry;                  
    iwhitelist public conversionwhitelist;              
    ierc20token[] public connectortokens;               
    ierc20token[] public quickbuypath;                  
    mapping (address => connector) public connectors;   
    uint32 private totalconnectorweight = 0;            
    uint32 public maxconversionfee = 0;                 
                                                        
    uint32 public conversionfee = 0;                    
    bool public conversionsenabled = true;              
    ierc20token[] private convertpath;

    
    event conversion(
        address indexed _fromtoken,
        address indexed _totoken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionfee
    );
    
    event pricedataupdate(
        address indexed _connectortoken,
        uint256 _tokensupply,
        uint256 _connectorbalance,
        uint32 _connectorweight
    );
    
    event conversionfeeupdate(uint32 _prevfee, uint32 _newfee);

    
    constructor(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee,
        ierc20token _connectortoken,
        uint32 _connectorweight
    )
        public
        smarttokencontroller(_token)
        validaddress(_registry)
        validmaxconversionfee(_maxconversionfee)
    {
        registry = _registry;
        icontractfeatures features = icontractfeatures(registry.addressof(contractids.contract_features));

        
        if (features != address(0))
            features.enablefeatures(featureids.converter_conversion_whitelist, true);

        maxconversionfee = _maxconversionfee;

        if (_connectortoken != address(0))
            addconnector(_connectortoken, _connectorweight, false);
    }

    
    modifier validconnector(ierc20token _address) {
        require(connectors[_address].isset);
        _;
    }

    
    modifier validtoken(ierc20token _address) {
        require(_address == token || connectors[_address].isset);
        _;
    }

    
    modifier validmaxconversionfee(uint32 _conversionfee) {
        require(_conversionfee >= 0 && _conversionfee <= max_conversion_fee);
        _;
    }

    
    modifier validconversionfee(uint32 _conversionfee) {
        require(_conversionfee >= 0 && _conversionfee <= maxconversionfee);
        _;
    }

    
    modifier validconnectorweight(uint32 _weight) {
        require(_weight > 0 && _weight <= max_weight);
        _;
    }

    
    modifier validconversionpath(ierc20token[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

    
    modifier conversionsallowed {
        assert(conversionsenabled);
        _;
    }

    
    modifier bancornetworkonly {
        ibancornetwork bancornetwork = ibancornetwork(registry.addressof(contractids.bancor_network));
        require(msg.sender == address(bancornetwork));
        _;
    }

    
    function connectortokencount() public view returns (uint16) {
        return uint16(connectortokens.length);
    }

    
    function setconversionwhitelist(iwhitelist _whitelist)
        public
        owneronly
        notthis(_whitelist)
    {
        conversionwhitelist = _whitelist;
    }

    
    function setquickbuypath(ierc20token[] _path)
        public
        owneronly
        validconversionpath(_path)
    {
        quickbuypath = _path;
    }

    
    function clearquickbuypath() public owneronly {
        quickbuypath.length = 0;
    }

    
    function getquickbuypathlength() public view returns (uint256) {
        return quickbuypath.length;
    }

    
    function disableconversions(bool _disable) public ownerormanageronly {
        conversionsenabled = !_disable;
    }

    
    function setconversionfee(uint32 _conversionfee)
        public
        ownerormanageronly
        validconversionfee(_conversionfee)
    {
        emit conversionfeeupdate(conversionfee, _conversionfee);
        conversionfee = _conversionfee;
    }

    
    function getfinalamount(uint256 _amount, uint8 _magnitude) public view returns (uint256) {
        return safemul(_amount, (max_conversion_fee  conversionfee) ** _magnitude) / max_conversion_fee ** _magnitude;
    }

    
    function addconnector(ierc20token _token, uint32 _weight, bool _enablevirtualbalance)
        public
        owneronly
        inactive
        validaddress(_token)
        notthis(_token)
        validconnectorweight(_weight)
    {
        require(_token != token && !connectors[_token].isset && totalconnectorweight + _weight <= max_weight); 

        connectors[_token].virtualbalance = 0;
        connectors[_token].weight = _weight;
        connectors[_token].isvirtualbalanceenabled = _enablevirtualbalance;
        connectors[_token].ispurchaseenabled = true;
        connectors[_token].isset = true;
        connectortokens.push(_token);
        totalconnectorweight += _weight;
    }

    
    function updateconnector(ierc20token _connectortoken, uint32 _weight, bool _enablevirtualbalance, uint256 _virtualbalance)
        public
        owneronly
        validconnector(_connectortoken)
        validconnectorweight(_weight)
    {
        connector storage connector = connectors[_connectortoken];
        require(totalconnectorweight  connector.weight + _weight <= max_weight); 

        totalconnectorweight = totalconnectorweight  connector.weight + _weight;
        connector.weight = _weight;
        connector.isvirtualbalanceenabled = _enablevirtualbalance;
        connector.virtualbalance = _virtualbalance;
    }

    
    function disableconnectorpurchases(ierc20token _connectortoken, bool _disable)
        public
        owneronly
        validconnector(_connectortoken)
    {
        connectors[_connectortoken].ispurchaseenabled = !_disable;
    }

    
    function getconnectorbalance(ierc20token _connectortoken)
        public
        view
        validconnector(_connectortoken)
        returns (uint256)
    {
        connector storage connector = connectors[_connectortoken];
        return connector.isvirtualbalanceenabled ? connector.virtualbalance : _connectortoken.balanceof(this);
    }

    
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public view returns (uint256, uint256) {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return getpurchasereturn(_fromtoken, _amount);
        else if (_fromtoken == token)
            return getsalereturn(_totoken, _amount);

        
        return getcrossconnectorreturn(_fromtoken, _totoken, _amount);
    }

    
    function getpurchasereturn(ierc20token _connectortoken, uint256 _depositamount)
        public
        view
        active
        validconnector(_connectortoken)
        returns (uint256, uint256)
    {
        connector storage connector = connectors[_connectortoken];
        require(connector.ispurchaseenabled); 

        uint256 tokensupply = token.totalsupply();
        uint256 connectorbalance = getconnectorbalance(_connectortoken);
        ibancorformula formula = ibancorformula(registry.addressof(contractids.bancor_formula));
        uint256 amount = formula.calculatepurchasereturn(tokensupply, connectorbalance, connector.weight, _depositamount);
        uint256 finalamount = getfinalamount(amount, 1);

        
        return (finalamount, amount  finalamount);
    }

    
    function getsalereturn(ierc20token _connectortoken, uint256 _sellamount)
        public
        view
        active
        validconnector(_connectortoken)
        returns (uint256, uint256)
    {
        connector storage connector = connectors[_connectortoken];
        uint256 tokensupply = token.totalsupply();
        uint256 connectorbalance = getconnectorbalance(_connectortoken);
        ibancorformula formula = ibancorformula(registry.addressof(contractids.bancor_formula));
        uint256 amount = formula.calculatesalereturn(tokensupply, connectorbalance, connector.weight, _sellamount);
        uint256 finalamount = getfinalamount(amount, 1);

        
        return (finalamount, amount  finalamount);
    }

    
    function getcrossconnectorreturn(ierc20token _fromconnectortoken, ierc20token _toconnectortoken, uint256 _sellamount)
        public
        view
        active
        validconnector(_fromconnectortoken)
        validconnector(_toconnectortoken)
        returns (uint256, uint256)
    {
        connector storage fromconnector = connectors[_fromconnectortoken];
        connector storage toconnector = connectors[_toconnectortoken];
        require(toconnector.ispurchaseenabled); 

        ibancorformula formula = ibancorformula(registry.addressof(contractids.bancor_formula));
        uint256 amount = formula.calculatecrossconnectorreturn(
            getconnectorbalance(_fromconnectortoken), 
            fromconnector.weight, 
            getconnectorbalance(_toconnectortoken), 
            toconnector.weight, 
            _sellamount);
        uint256 finalamount = getfinalamount(amount, 2);

        
        
        return (finalamount, amount  finalamount);
    }

    
    function convertinternal(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn)
        public
        bancornetworkonly
        conversionsallowed
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return buy(_fromtoken, _amount, _minreturn);
        else if (_fromtoken == token)
            return sell(_totoken, _amount, _minreturn);

        uint256 amount;
        uint256 feeamount;

        
        (amount, feeamount) = getcrossconnectorreturn(_fromtoken, _totoken, _amount);
        
        require(amount != 0 && amount >= _minreturn);

        
        connector storage fromconnector = connectors[_fromtoken];
        if (fromconnector.isvirtualbalanceenabled)
            fromconnector.virtualbalance = safeadd(fromconnector.virtualbalance, _amount);

        
        connector storage toconnector = connectors[_totoken];
        if (toconnector.isvirtualbalanceenabled)
            toconnector.virtualbalance = safesub(toconnector.virtualbalance, amount);

        
        uint256 toconnectorbalance = getconnectorbalance(_totoken);
        assert(amount < toconnectorbalance);

        
        assert(_fromtoken.transferfrom(msg.sender, this, _amount));
        
        
        assert(_totoken.transfer(msg.sender, amount));

        
        
        dispatchconversionevent(_fromtoken, _totoken, _amount, amount, feeamount);

        
        emit pricedataupdate(_fromtoken, token.totalsupply(), getconnectorbalance(_fromtoken), fromconnector.weight);
        emit pricedataupdate(_totoken, token.totalsupply(), getconnectorbalance(_totoken), toconnector.weight);
        return amount;
    }

    
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        convertpath = [_fromtoken, token, _totoken];
        return quickconvert(convertpath, _amount, _minreturn);
    }

    
    function buy(ierc20token _connectortoken, uint256 _depositamount, uint256 _minreturn) internal returns (uint256) {
        uint256 amount;
        uint256 feeamount;
        (amount, feeamount) = getpurchasereturn(_connectortoken, _depositamount);
        
        require(amount != 0 && amount >= _minreturn);

        
        connector storage connector = connectors[_connectortoken];
        if (connector.isvirtualbalanceenabled)
            connector.virtualbalance = safeadd(connector.virtualbalance, _depositamount);

        
        assert(_connectortoken.transferfrom(msg.sender, this, _depositamount));
        
        token.issue(msg.sender, amount);

        
        dispatchconversionevent(_connectortoken, token, _depositamount, amount, feeamount);

        
        emit pricedataupdate(_connectortoken, token.totalsupply(), getconnectorbalance(_connectortoken), connector.weight);
        return amount;
    }

    
    function sell(ierc20token _connectortoken, uint256 _sellamount, uint256 _minreturn) internal returns (uint256) {
        require(_sellamount <= token.balanceof(msg.sender)); 
        uint256 amount;
        uint256 feeamount;
        (amount, feeamount) = getsalereturn(_connectortoken, _sellamount);
        
        require(amount != 0 && amount >= _minreturn);

        
        uint256 tokensupply = token.totalsupply();
        uint256 connectorbalance = getconnectorbalance(_connectortoken);
        assert(amount < connectorbalance || (amount == connectorbalance && _sellamount == tokensupply));

        
        connector storage connector = connectors[_connectortoken];
        if (connector.isvirtualbalanceenabled)
            connector.virtualbalance = safesub(connector.virtualbalance, amount);

        
        token.destroy(msg.sender, _sellamount);
        
        
        assert(_connectortoken.transfer(msg.sender, amount));

        
        dispatchconversionevent(token, _connectortoken, _sellamount, amount, feeamount);

        
        emit pricedataupdate(_connectortoken, token.totalsupply(), getconnectorbalance(_connectortoken), connector.weight);
        return amount;
    }

    
    function quickconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn)
        public
        payable
        validconversionpath(_path)
        returns (uint256)
    {
        return quickconvertprioritized(_path, _amount, _minreturn, 0x0, 0x0, 0x0, 0x0);
    }

    
    function quickconvertprioritized(ierc20token[] _path, uint256 _amount, uint256 _minreturn, uint256 _block, uint8 _v, bytes32 _r, bytes32 _s)
        public
        payable
        validconversionpath(_path)
        returns (uint256)
    {
        ierc20token fromtoken = _path[0];
        ibancornetwork bancornetwork = ibancornetwork(registry.addressof(contractids.bancor_network));

        
        
        if (msg.value == 0) {
            
            
            
            if (fromtoken == token) {
                token.destroy(msg.sender, _amount); 
                token.issue(bancornetwork, _amount); 
            } else {
                
                assert(fromtoken.transferfrom(msg.sender, bancornetwork, _amount));
            }
        }

        
        return bancornetwork.convertforprioritized2.value(msg.value)(_path, _amount, _minreturn, msg.sender, _block, _v, _r, _s);
    }

    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return convertinternal(_fromtoken, _totoken, _amount, _minreturn);
    }

    
    function dispatchconversionevent(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _returnamount, uint256 _feeamount) private {
        
        
        
        
        assert(_feeamount <= 2 ** 255);
        emit conversion(_fromtoken, _totoken, msg.sender, _amount, _returnamount, int256(_feeamount));
    }

    
    function() payable public {
        quickconvert(quickbuypath, msg.value, 1);
    }
}
