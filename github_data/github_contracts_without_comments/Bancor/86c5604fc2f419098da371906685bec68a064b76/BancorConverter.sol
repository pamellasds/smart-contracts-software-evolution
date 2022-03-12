pragma solidity ^0.4.11;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract bancorconverter is itokenconverter, smarttokencontroller, managed {
    uint32 private constant max_crr = 1000000;
    uint32 private constant max_conversion_fee = 1000000;

    struct reserve {
        uint256 virtualbalance;         
        uint32 ratio;                   
        bool isvirtualbalanceenabled;   
        bool ispurchaseenabled;         
        bool isset;                     
    }

    string public version = ;
    string public convertertype = ;

    ibancorconverterextensions public extensions;   
    ierc20token[] public reservetokens;             
    ierc20token[] public quickbuypath;              
    mapping (address => reserve) public reserves;   
    uint32 private totalreserveratio = 0;           
    uint32 public maxconversionfee = 0;             
    uint32 public conversionfee = 0;                
    bool public conversionsenabled = true;          

    
    event conversion(address indexed _fromtoken, address indexed _totoken, address indexed _trader, uint256 _amount, uint256 _return,
                     uint256 _currentpricen, uint256 _currentpriced);

    
    function bancorconverter(ismarttoken _token, ibancorconverterextensions _extensions, uint32 _maxconversionfee, ierc20token _reservetoken, uint32 _reserveratio)
        smarttokencontroller(_token)
        validaddress(_extensions)
        validmaxconversionfee(_maxconversionfee)
    {
        extensions = _extensions;
        maxconversionfee = _maxconversionfee;

        if (address(_reservetoken) != 0x0)
            addreserve(_reservetoken, _reserveratio, false);
    }

    
    modifier validreserve(ierc20token _address) {
        require(reserves[_address].isset);
        _;
    }

    
    modifier validtoken(ierc20token _address) {
        require(_address == token || reserves[_address].isset);
        _;
    }

    
    modifier validgasprice() {
        assert(tx.gasprice <= extensions.gaspricelimit().gasprice());
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

    
    modifier validreserveratio(uint32 _ratio) {
        require(_ratio > 0 && _ratio <= max_crr);
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

    
    function reservetokencount() public constant returns (uint16) {
        return uint16(reservetokens.length);
    }

    
    function convertibletokencount() public constant returns (uint16) {
        return reservetokencount() + 1;
    }

    
    function convertibletoken(uint16 _tokenindex) public constant returns (address) {
        if (_tokenindex == 0)
            return token;
        return reservetokens[_tokenindex  1];
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

    
    function getquickbuypathlength() public constant returns (uint256) {
        return quickbuypath.length;
    }

    
    function disableconversions(bool _disable) public manageronly {
        conversionsenabled = !_disable;
    }

    
    function setconversionfee(uint32 _conversionfee)
        public
        manageronly
        validconversionfee(_conversionfee)
    {
        conversionfee = _conversionfee;
    }

    
    function getconversionfeeamount(uint256 _amount) public constant returns (uint256) {
        return safemul(_amount, conversionfee) / max_conversion_fee;
    }

    
    function addreserve(ierc20token _token, uint32 _ratio, bool _enablevirtualbalance)
        public
        owneronly
        inactive
        validaddress(_token)
        notthis(_token)
        validreserveratio(_ratio)
    {
        require(_token != token && !reserves[_token].isset && totalreserveratio + _ratio <= max_crr); 

        reserves[_token].virtualbalance = 0;
        reserves[_token].ratio = _ratio;
        reserves[_token].isvirtualbalanceenabled = _enablevirtualbalance;
        reserves[_token].ispurchaseenabled = true;
        reserves[_token].isset = true;
        reservetokens.push(_token);
        totalreserveratio += _ratio;
    }

    
    function updatereserve(ierc20token _reservetoken, uint32 _ratio, bool _enablevirtualbalance, uint256 _virtualbalance)
        public
        owneronly
        validreserve(_reservetoken)
        validreserveratio(_ratio)
    {
        reserve storage reserve = reserves[_reservetoken];
        require(totalreserveratio  reserve.ratio + _ratio <= max_crr); 

        totalreserveratio = totalreserveratio  reserve.ratio + _ratio;
        reserve.ratio = _ratio;
        reserve.isvirtualbalanceenabled = _enablevirtualbalance;
        reserve.virtualbalance = _virtualbalance;
    }

    
    function disablereservepurchases(ierc20token _reservetoken, bool _disable)
        public
        owneronly
        validreserve(_reservetoken)
    {
        reserves[_reservetoken].ispurchaseenabled = !_disable;
    }

    
    function getreservebalance(ierc20token _reservetoken)
        public
        constant
        validreserve(_reservetoken)
        returns (uint256)
    {
        reserve storage reserve = reserves[_reservetoken];
        return reserve.isvirtualbalanceenabled ? reserve.virtualbalance : _reservetoken.balanceof(this);
    }

    
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public constant returns (uint256) {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return getpurchasereturn(_fromtoken, _amount);
        else if (_fromtoken == token)
            return getsalereturn(_totoken, _amount);

        
        uint256 purchasereturnamount = getpurchasereturn(_fromtoken, _amount);
        return getsalereturn(_totoken, purchasereturnamount, safeadd(token.totalsupply(), purchasereturnamount));
    }

    
    function getpurchasereturn(ierc20token _reservetoken, uint256 _depositamount)
        public
        constant
        active
        validreserve(_reservetoken)
        returns (uint256)
    {
        reserve storage reserve = reserves[_reservetoken];
        require(reserve.ispurchaseenabled); 

        uint256 tokensupply = token.totalsupply();
        uint256 reservebalance = getreservebalance(_reservetoken);
        uint256 amount = extensions.formula().calculatepurchasereturn(tokensupply, reservebalance, reserve.ratio, _depositamount);

        
        uint256 feeamount = getconversionfeeamount(amount);
        return safesub(amount, feeamount);
    }

    
    function getsalereturn(ierc20token _reservetoken, uint256 _sellamount) public constant returns (uint256) {
        return getsalereturn(_reservetoken, _sellamount, token.totalsupply());
    }

    
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return buy(_fromtoken, _amount, _minreturn);
        else if (_fromtoken == token)
            return sell(_totoken, _amount, _minreturn);

        
        uint256 purchaseamount = buy(_fromtoken, _amount, 1);
        return sell(_totoken, purchaseamount, _minreturn);
    }

    
    function buy(ierc20token _reservetoken, uint256 _depositamount, uint256 _minreturn)
        public
        conversionsallowed
        validgasprice
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        uint256 amount = getpurchasereturn(_reservetoken, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 

        
        reserve storage reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safeadd(reserve.virtualbalance, _depositamount);

        
        assert(_reservetoken.transferfrom(msg.sender, this, _depositamount));
        
        token.issue(msg.sender, amount);

        
        
        
        uint256 reserveamount = safemul(getreservebalance(_reservetoken), max_crr);
        uint256 tokenamount = safemul(token.totalsupply(), reserve.ratio);
        conversion(_reservetoken, token, msg.sender, _depositamount, amount, reserveamount, tokenamount);
        return amount;
    }

    
    function sell(ierc20token _reservetoken, uint256 _sellamount, uint256 _minreturn)
        public
        conversionsallowed
        validgasprice
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        require(_sellamount <= token.balanceof(msg.sender)); 

        uint256 amount = getsalereturn(_reservetoken, _sellamount);
        assert(amount != 0 && amount >= _minreturn); 

        uint256 tokensupply = token.totalsupply();
        uint256 reservebalance = getreservebalance(_reservetoken);
        
        assert(amount < reservebalance || (amount == reservebalance && _sellamount == tokensupply));

        
        reserve storage reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safesub(reserve.virtualbalance, amount);

        
        token.destroy(msg.sender, _sellamount);
        
        
        assert(_reservetoken.transfer(msg.sender, amount));

        
        
        
        uint256 reserveamount = safemul(getreservebalance(_reservetoken), max_crr);
        uint256 tokenamount = safemul(token.totalsupply(), reserve.ratio);
        conversion(token, _reservetoken, msg.sender, _sellamount, amount, tokenamount, reserveamount);
        return amount;
    }

    
    function quickconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn)
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
            }
            else {
                
                assert(fromtoken.transferfrom(msg.sender, quickconverter, _amount));
            }
        }

        
        return quickconverter.convertfor.value(msg.value)(_path, _amount, _minreturn, msg.sender);
    }

    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return convert(_fromtoken, _totoken, _amount, _minreturn);
    }

    
    function quickchange(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return quickconvert(_path, _amount, _minreturn);
    }

    
    function quickbuy(uint256 _minreturn) public payable returns (uint256) {
        return quickconvert(quickbuypath, msg.value, _minreturn);
    }

    
    function hasquickbuyethertoken() public constant returns (bool) {
        return quickbuypath.length > 0;
    }

    
    function getquickbuyethertoken() public constant returns (iethertoken) {
        assert(quickbuypath.length > 0);
        return iethertoken(quickbuypath[0]);
    }

    
    function getsalereturn(ierc20token _reservetoken, uint256 _sellamount, uint256 _totalsupply)
        private
        constant
        active
        validreserve(_reservetoken)
        greaterthanzero(_totalsupply)
        returns (uint256)
    {
        reserve storage reserve = reserves[_reservetoken];
        uint256 reservebalance = getreservebalance(_reservetoken);
        uint256 amount = extensions.formula().calculatesalereturn(_totalsupply, reservebalance, reserve.ratio, _sellamount);

        
        uint256 feeamount = getconversionfeeamount(amount);
        return safesub(amount, feeamount);
    }

    
    function() payable {
        quickconvert(quickbuypath, msg.value, 1);
    }
}
