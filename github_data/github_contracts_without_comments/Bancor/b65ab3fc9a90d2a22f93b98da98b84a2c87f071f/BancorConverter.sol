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
import ;


contract bancorconverter is ibancorconverter, smarttokencontroller, managed, contractids, featureids {
    using safemath for uint256;

    
    uint32 private constant max_weight = 1000000;
    uint64 private constant max_conversion_fee = 1000000;

    struct connector {
        uint256 virtualbalance;         
        uint32 weight;                  
        bool isvirtualbalanceenabled;   
        bool issaleenabled;             
        bool isset;                     
    }

    uint16 public version = 13;
    string public convertertype = ;

    bool public allowregistryupdate = true;             
    bool public claimtokensenabled = false;             
    icontractregistry public prevregistry;              
    icontractregistry public registry;                  
    iwhitelist public conversionwhitelist;              
    ierc20token[] public connectortokens;               
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

    
    event conversionsenable(bool _conversionsenabled);

    
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
        prevregistry = _registry;
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

    
    modifier maxtotalweightonly() {
        require(totalconnectorweight == max_weight);
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

    
    modifier converterupgraderonly {
        address converterupgrader = registry.addressof(contractids.bancor_converter_upgrader);
        require(owner == converterupgrader);
        _;
    }

    
    modifier whenclaimtokensenabled {
        require(claimtokensenabled);
        _;
    }

    
    function updateregistry() public {
        
        require(allowregistryupdate || msg.sender == owner);

        
        address newregistry = registry.addressof(contractids.contract_registry);

        
        require(newregistry != address(registry) && newregistry != address(0));

        
        prevregistry = registry;
        registry = icontractregistry(newregistry);
    }

    
    function restoreregistry() public ownerormanageronly {
        
        registry = prevregistry;

        
        allowregistryupdate = false;
    }

    
    function disableregistryupdate(bool _disable) public ownerormanageronly {
        allowregistryupdate = !_disable;
    }

    
    function enableclaimtokens(bool _enable) public owneronly {
        claimtokensenabled = _enable;
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

    
    function disableconversions(bool _disable) public ownerormanageronly {
        if (conversionsenabled == _disable) {
            conversionsenabled = !_disable;
            emit conversionsenable(conversionsenabled);
        }
    }

    
    function transfertokenownership(address _newowner)
        public
        owneronly
        converterupgraderonly
    {
        super.transfertokenownership(_newowner);
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
        return _amount.mul((max_conversion_fee  conversionfee) ** _magnitude).div(max_conversion_fee ** _magnitude);
    }

    
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public {
        address converterupgrader = registry.addressof(contractids.bancor_converter_upgrader);

        
        
        require(!connectors[_token].isset || token.owner() != address(this) || owner == converterupgrader);
        super.withdrawtokens(_token, _to, _amount);
    }

    
    function claimtokens(address _from, uint256 _amount) public whenclaimtokensenabled {
        address bancorx = registry.addressof(contractids.bancor_x);

        
        require(msg.sender == bancorx);

        
        token.destroy(_from, _amount);
        token.issue(msg.sender, _amount);
    }

    
    function upgrade() public owneronly {
        ibancorconverterupgrader converterupgrader = ibancorconverterupgrader(registry.addressof(contractids.bancor_converter_upgrader));

        transferownership(converterupgrader);
        converterupgrader.upgrade(version);
        acceptownership();
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
        connectors[_token].issaleenabled = true;
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

    
    function disableconnectorsale(ierc20token _connectortoken, bool _disable)
        public
        owneronly
        validconnector(_connectortoken)
    {
        connectors[_connectortoken].issaleenabled = !_disable;
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
        require(connector.issaleenabled); 

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
        require(fromconnector.issaleenabled); 

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
            fromconnector.virtualbalance = fromconnector.virtualbalance.add(_amount);

        
        connector storage toconnector = connectors[_totoken];
        if (toconnector.isvirtualbalanceenabled)
            toconnector.virtualbalance = toconnector.virtualbalance.sub(amount);

        
        uint256 toconnectorbalance = getconnectorbalance(_totoken);
        assert(amount < toconnectorbalance);

        
        ensuretransferfrom(_fromtoken, msg.sender, this, _amount);
        
        
        ensuretransfer(_totoken, msg.sender, amount);

        
        
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
            connector.virtualbalance = connector.virtualbalance.add(_depositamount);

        
        ensuretransferfrom(_connectortoken, msg.sender, this, _depositamount);
        
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
            connector.virtualbalance = connector.virtualbalance.sub(amount);

        
        token.destroy(msg.sender, _sellamount);
        
        
        ensuretransfer(_connectortoken, msg.sender, amount);

        
        dispatchconversionevent(token, _connectortoken, _sellamount, amount, feeamount);

        
        emit pricedataupdate(_connectortoken, token.totalsupply(), getconnectorbalance(_connectortoken), connector.weight);
        return amount;
    }

    
    function quickconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn)
        public
        payable
        returns (uint256)
    {
        return quickconvertprioritized(_path, _amount, _minreturn, 0x0, 0x0, 0x0, 0x0);
    }

    
    function quickconvertprioritized(ierc20token[] _path, uint256 _amount, uint256 _minreturn, uint256 _block, uint8 _v, bytes32 _r, bytes32 _s)
        public
        payable
        returns (uint256)
    {
        ierc20token fromtoken = _path[0];
        ibancornetwork bancornetwork = ibancornetwork(registry.addressof(contractids.bancor_network));

        
        
        if (msg.value == 0) {
            
            
            
            if (fromtoken == token) {
                token.destroy(msg.sender, _amount); 
                token.issue(bancornetwork, _amount); 
            } else {
                
                ensuretransferfrom(fromtoken, msg.sender, bancornetwork, _amount);
            }
        }

        
        return bancornetwork.convertforprioritized3.value(msg.value)(_path, _amount, _minreturn, msg.sender, _amount, _block, _v, _r, _s);
    }

    
    function completexconversion(
        ierc20token[] _path,
        uint256 _minreturn,
        uint256 _conversionid,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        returns (uint256)
    {
        ibancorx bancorx = ibancorx(registry.addressof(contractids.bancor_x));
        ibancornetwork bancornetwork = ibancornetwork(registry.addressof(contractids.bancor_network));

        
        require(_path[0] == registry.addressof(contractids.bnt_token));

        
        uint256 amount = bancorx.getxtransferamount(_conversionid, msg.sender);

        
        token.destroy(msg.sender, amount);
        token.issue(bancornetwork, amount);

        return bancornetwork.convertforprioritized3(_path, amount, _minreturn, msg.sender, _conversionid, _block, _v, _r, _s);
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

    
    function fund(uint256 _amount)
        public
        maxtotalweightonly
        conversionsallowed
    {
        uint256 supply = token.totalsupply();

        
        
        ierc20token connectortoken;
        uint256 connectorbalance;
        uint256 connectoramount;
        for (uint16 i = 0; i < connectortokens.length; i++) {
            connectortoken = connectortokens[i];
            connectorbalance = getconnectorbalance(connectortoken);
            connectoramount = _amount.mul(connectorbalance).div(supply);

            
            connector storage connector = connectors[connectortoken];
            if (connector.isvirtualbalanceenabled)
                connector.virtualbalance = connector.virtualbalance.add(connectoramount);

            
            ensuretransferfrom(connectortoken, msg.sender, this, connectoramount);

            
            emit pricedataupdate(connectortoken, supply + _amount, connectorbalance + connectoramount, connector.weight);
        }

        
        token.issue(msg.sender, _amount);
    }

    
    function liquidate(uint256 _amount) public maxtotalweightonly {
        uint256 supply = token.totalsupply();

        
        token.destroy(msg.sender, _amount);

        
        
        ierc20token connectortoken;
        uint256 connectorbalance;
        uint256 connectoramount;
        for (uint16 i = 0; i < connectortokens.length; i++) {
            connectortoken = connectortokens[i];
            connectorbalance = getconnectorbalance(connectortoken);
            connectoramount = _amount.mul(connectorbalance).div(supply);

            
            connector storage connector = connectors[connectortoken];
            if (connector.isvirtualbalanceenabled)
                connector.virtualbalance = connector.virtualbalance.sub(connectoramount);

            
            
            ensuretransfer(connectortoken, msg.sender, connectoramount);

            
            emit pricedataupdate(connectortoken, supply  _amount, connectorbalance  connectoramount, connector.weight);
        }
    }

    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return convertinternal(_fromtoken, _totoken, _amount, _minreturn);
    }

    
    function dispatchconversionevent(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _returnamount, uint256 _feeamount) private {
        
        
        
        
        assert(_feeamount <= 2 ** 255);
        emit conversion(_fromtoken, _totoken, msg.sender, _amount, _returnamount, int256(_feeamount));
    }
}
