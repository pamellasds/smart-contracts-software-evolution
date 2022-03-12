pragma solidity ^0.4.21;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract bancorconverter is itokenconverter, smarttokencontroller, managed {
    uint32 private constant max_weight = 1000000;
    uint32 private constant max_conversion_fee = 1000000;

    struct connector {
        uint256 virtualbalance;         
        uint32 weight;                  
        bool isvirtualbalanceenabled;   
        bool ispurchaseenabled;         
        bool isset;                     
    }

    string public version = ;
    string public convertertype = ;

    ibancorconverterextensions public extensions;       
    ierc20token[] public connectortokens;               
    ierc20token[] public quickbuypath;                  
    mapping (address => connector) public connectors;   
    uint32 private totalconnectorweight = 0;            
    uint32 public maxconversionfee = 0;                 
    uint32 public conversionfee = 0;                    
    bool public conversionsenabled = true;              
    ierc20token[] private convertpath;

    
    event conversion(address indexed _fromtoken,
        address indexed _totoken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionfee,
        uint256 _currentpricen,
        uint256 _currentpriced
    );
    
    event conversionfeeupdate(uint32 _prevfee, uint32 _newfee);

    
    function bancorconverter(ismarttoken _token, ibancorconverterextensions _extensions, uint32 _maxconversionfee, ierc20token _connectortoken, uint32 _connectorweight)
        public
        smarttokencontroller(_token)
        validaddress(_extensions)
        validmaxconversionfee(_maxconversionfee)
    {
        extensions = _extensions;
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

    
    modifier ownerormanageronly {
        require(msg.sender == owner || msg.sender == manager);
        _;
    }

    
    modifier quickconverteronly {
        require(msg.sender == address(extensions.quickconverter()));
        _;
    }

    
    function connectortokencount() public view returns (uint16) {
        return uint16(connectortokens.length);
    }

    
    function convertibletokencount() public view returns (uint16) {
        return connectortokencount() + 1;
    }

    
    function convertibletoken(uint16 _tokenindex) public view returns (address) {
        if (_tokenindex == 0)
            return token;
        return connectortokens[_tokenindex  1];
    }

    
    function setextensions(ibancorconverterextensions _extensions)
        public
        owneronly
        validaddress(_extensions)
        notthis(_extensions)
    {
        extensions = _extensions;
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

    
    function getconversionfeeamount(uint256 _amount) public view returns (uint256) {
        return safemul(_amount, conversionfee) / max_conversion_fee;
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

    
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public view returns (uint256) {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return getpurchasereturn(_fromtoken, _amount);
        else if (_fromtoken == token)
            return getsalereturn(_totoken, _amount);

        
        uint256 purchasereturnamount = getpurchasereturn(_fromtoken, _amount);
        return getsalereturn(_totoken, purchasereturnamount, safeadd(token.totalsupply(), purchasereturnamount));
    }

    
    function getpurchasereturn(ierc20token _connectortoken, uint256 _depositamount)
        public
        view
        active
        validconnector(_connectortoken)
        returns (uint256)
    {
        connector storage connector = connectors[_connectortoken];
        require(connector.ispurchaseenabled); 

        uint256 tokensupply = token.totalsupply();
        uint256 connectorbalance = getconnectorbalance(_connectortoken);
        uint256 amount = extensions.formula().calculatepurchasereturn(tokensupply, connectorbalance, connector.weight, _depositamount);

        
        uint256 feeamount = getconversionfeeamount(amount);
        return safesub(amount, feeamount);
    }

    
    function getsalereturn(ierc20token _connectortoken, uint256 _sellamount) public view returns (uint256) {
        return getsalereturn(_connectortoken, _sellamount, token.totalsupply());
    }

    
    function convertinternal(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public quickconverteronly returns (uint256) {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return buy(_fromtoken, _amount, _minreturn);
        else if (_fromtoken == token)
            return sell(_totoken, _amount, _minreturn);

        
        uint256 purchaseamount = buy(_fromtoken, _amount, 1);
        return sell(_totoken, purchaseamount, _minreturn);
    }

    
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        convertpath = [_fromtoken, token, _totoken];
        return quickconvert(convertpath, _amount, _minreturn);
    }

    
    function buy(ierc20token _connectortoken, uint256 _depositamount, uint256 _minreturn)
        internal
        conversionsallowed
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        uint256 amount = getpurchasereturn(_connectortoken, _depositamount);
        require(amount != 0 && amount >= _minreturn); 

        
        connector storage connector = connectors[_connectortoken];
        if (connector.isvirtualbalanceenabled)
            connector.virtualbalance = safeadd(connector.virtualbalance, _depositamount);

        
        assert(_connectortoken.transferfrom(msg.sender, this, _depositamount));
        
        token.issue(msg.sender, amount);

        dispatchconversionevent(_connectortoken, _depositamount, amount, true);
        return amount;
    }

    
    function sell(ierc20token _connectortoken, uint256 _sellamount, uint256 _minreturn)
        internal
        conversionsallowed
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        require(_sellamount <= token.balanceof(msg.sender)); 

        uint256 amount = getsalereturn(_connectortoken, _sellamount);
        require(amount != 0 && amount >= _minreturn); 

        uint256 tokensupply = token.totalsupply();
        uint256 connectorbalance = getconnectorbalance(_connectortoken);
        
        assert(amount < connectorbalance || (amount == connectorbalance && _sellamount == tokensupply));

        
        connector storage connector = connectors[_connectortoken];
        if (connector.isvirtualbalanceenabled)
            connector.virtualbalance = safesub(connector.virtualbalance, amount);

        
        token.destroy(msg.sender, _sellamount);
        
        
        assert(_connectortoken.transfer(msg.sender, amount));

        dispatchconversionevent(_connectortoken, _sellamount, amount, false);
        return amount;
    }

    
    function quickconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn)
        public
        payable
        validconversionpath(_path)
        returns (uint256)
    {
        return quickconvertprioritized(_path, _amount, _minreturn, 0x0, 0x0, 0x0, 0x0, 0x0);
    }

    
    function quickconvertprioritized(ierc20token[] _path, uint256 _amount, uint256 _minreturn, uint256 _block, uint256 _nonce, uint8 _v, bytes32 _r, bytes32 _s)
        public
        payable
        validconversionpath(_path)
        returns (uint256)
    {
        ierc20token fromtoken = _path[0];
        ibancorquickconverter quickconverter = extensions.quickconverter();

        
        
        if (msg.value == 0) {
            
            
            if (fromtoken == token) {
                token.destroy(msg.sender, _amount); 
                token.issue(quickconverter, _amount); 
            } else {
                
                assert(fromtoken.transferfrom(msg.sender, quickconverter, _amount));
            }
        }

        
        return quickconverter.convertforprioritized.value(msg.value)(_path, _amount, _minreturn, msg.sender, _block, _nonce, _v, _r, _s);
    }

    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return convertinternal(_fromtoken, _totoken, _amount, _minreturn);
    }

    
    function getsalereturn(ierc20token _connectortoken, uint256 _sellamount, uint256 _totalsupply)
        private
        view
        active
        validconnector(_connectortoken)
        greaterthanzero(_totalsupply)
        returns (uint256)
    {
        connector storage connector = connectors[_connectortoken];
        uint256 connectorbalance = getconnectorbalance(_connectortoken);
        uint256 amount = extensions.formula().calculatesalereturn(_totalsupply, connectorbalance, connector.weight, _sellamount);

        
        uint256 feeamount = getconversionfeeamount(amount);
        return safesub(amount, feeamount);
    }

    
    function dispatchconversionevent(ierc20token _connectortoken, uint256 _amount, uint256 _returnamount, bool ispurchase) private {
        connector storage connector = connectors[_connectortoken];

        
        
        
        uint256 connectoramount = safemul(getconnectorbalance(_connectortoken), max_weight);
        uint256 tokenamount = safemul(token.totalsupply(), connector.weight);

        
        uint8 tokendecimals = token.decimals();
        uint8 connectortokendecimals = _connectortoken.decimals();
        if (tokendecimals != connectortokendecimals) {
            if (tokendecimals > connectortokendecimals)
                connectoramount = safemul(connectoramount, 10 ** uint256(tokendecimals  connectortokendecimals));
            else
                tokenamount = safemul(tokenamount, 10 ** uint256(connectortokendecimals  tokendecimals));
        }

        uint256 feeamount = getconversionfeeamount(_returnamount);
        
        assert(feeamount <= 2 ** 255);

        if (ispurchase)
            emit conversion(_connectortoken, token, msg.sender, _amount, _returnamount, int256(feeamount), connectoramount, tokenamount);
        else
            emit conversion(token, _connectortoken, msg.sender, _amount, _returnamount, int256(feeamount), tokenamount, connectoramount);
    }

    
    function() payable public {
        quickconvert(quickbuypath, msg.value, 1);
    }
}
