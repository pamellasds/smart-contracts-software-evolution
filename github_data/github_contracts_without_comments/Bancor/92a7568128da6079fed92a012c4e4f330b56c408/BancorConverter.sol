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


contract bancorconverter is ibancorconverter, smarttokencontroller, managed, contractregistryclient, featureids {
    using safemath for uint256;

    uint32 private constant ratio_resolution = 1000000;
    uint64 private constant conversion_fee_resolution = 1000000;

    struct reserve {
        uint256 virtualbalance;         
        uint32 ratio;                   
        bool isvirtualbalanceenabled;   
        bool issaleenabled;             
        bool isset;                     
    }

    
    uint16 public version = 22;
    string public convertertype = ;

    iwhitelist public conversionwhitelist;              
    ierc20token[] public reservetokens;                 
    mapping (address => reserve) public reserves;       
    uint32 private totalreserveratio = 0;               
    uint32 public maxconversionfee = 0;                 
                                                        
    uint32 public conversionfee = 0;                    
    bool public conversionsenabled = true;              

    
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

    
    event virtualbalancesenable(bool _enabled);

    
    constructor(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee,
        ierc20token _reservetoken,
        uint32 _reserveratio
    )   contractregistryclient(_registry)
        public
        smarttokencontroller(_token)
        validconversionfee(_maxconversionfee)
    {
        icontractfeatures features = icontractfeatures(addressof(contract_features));

        
        if (features != address(0))
            features.enablefeatures(featureids.converter_conversion_whitelist, true);

        maxconversionfee = _maxconversionfee;

        if (_reservetoken != address(0))
            addreserve(_reservetoken, _reserveratio);
    }

    
    modifier validreserve(ierc20token _address) {
        require(reserves[_address].isset);
        _;
    }

    
    modifier validconversionfee(uint32 _conversionfee) {
        require(_conversionfee >= 0 && _conversionfee <= conversion_fee_resolution);
        _;
    }

    
    modifier validreserveratio(uint32 _ratio) {
        require(_ratio > 0 && _ratio <= ratio_resolution);
        _;
    }

    
    modifier conversionsallowed {
        require(conversionsenabled);
        _;
    }

    
    modifier totalsupplygreaterthanzeroonly {
        require(token.totalsupply() > 0);
        _;
    }

    
    modifier multiplereservesonly {
        require(reservetokens.length > 1);
        _;
    }

    
    function reservetokencount() public view returns (uint16) {
        return uint16(reservetokens.length);
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
        only(bancor_converter_upgrader)
    {
        super.transfertokenownership(_newowner);
    }

    
    function accepttokenownership()
        public
        owneronly
        totalsupplygreaterthanzeroonly
    {
        super.accepttokenownership();
    }

    
    function setconversionfee(uint32 _conversionfee)
        public
        ownerormanageronly
    {
        require(_conversionfee >= 0 && _conversionfee <= maxconversionfee);
        emit conversionfeeupdate(conversionfee, _conversionfee);
        conversionfee = _conversionfee;
    }

    
    function getfinalamount(uint256 _amount, uint8 _magnitude) public view returns (uint256) {
        return _amount.mul((conversion_fee_resolution  conversionfee) ** _magnitude).div(conversion_fee_resolution ** _magnitude);
    }

    
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public {
        address converterupgrader = addressof(bancor_converter_upgrader);

        
        
        require(!reserves[_token].isset || token.owner() != address(this) || owner == converterupgrader);
        super.withdrawtokens(_token, _to, _amount);
    }

    
    function upgrade() public owneronly {
        ibancorconverterupgrader converterupgrader = ibancorconverterupgrader(addressof(bancor_converter_upgrader));

        transferownership(converterupgrader);
        converterupgrader.upgrade(version);
        acceptownership();
    }

    
    function addreserve(ierc20token _token, uint32 _ratio)
        public
        owneronly
        inactive
        validaddress(_token)
        notthis(_token)
        validreserveratio(_ratio)
    {
        require(_token != token && !reserves[_token].isset && totalreserveratio + _ratio <= ratio_resolution); 

        reserves[_token].ratio = _ratio;
        reserves[_token].isvirtualbalanceenabled = false;
        reserves[_token].virtualbalance = 0;
        reserves[_token].issaleenabled = true;
        reserves[_token].isset = true;
        reservetokens.push(_token);
        totalreserveratio += _ratio;
    }

    
    function updatereservevirtualbalance(ierc20token _reservetoken, uint256 _virtualbalance)
        public
        owneronly
        only(bancor_converter_upgrader)
        validreserve(_reservetoken)
    {
        reserve storage reserve = reserves[_reservetoken];
        reserve.isvirtualbalanceenabled = _virtualbalance != 0;
        reserve.virtualbalance = _virtualbalance;
    }

    
    function enablevirtualbalances(uint16 _scalefactor)
        public
        owneronly
        active
    {
        
        require(_scalefactor >= 100 && _scalefactor <= 1000);
        bool enable = _scalefactor != 100;

        
        
        ierc20token reservetoken;
        for (uint16 i = 0; i < reservetokens.length; i++) {
            reservetoken = reservetokens[i];
            reserve storage reserve = reserves[reservetoken];
            reserve.isvirtualbalanceenabled = enable;
            reserve.virtualbalance = enable ? reservetoken.balanceof(this).mul(_scalefactor).div(100) : 0;
        }

        emit virtualbalancesenable(enable);
    }

    
    function disablereservesale(ierc20token _reservetoken, bool _disable)
        public
        owneronly
        validreserve(_reservetoken)
    {
        reserves[_reservetoken].issaleenabled = !_disable;
    }

    
    function getreserveratio(ierc20token _reservetoken)
        public
        view
        validreserve(_reservetoken)
        returns (uint256)
    {
        return reserves[_reservetoken].ratio;
    }

    
    function getreservebalance(ierc20token _reservetoken)
        public
        view
        validreserve(_reservetoken)
        returns (uint256)
    {
        reserve storage reserve = reserves[_reservetoken];
        return reserve.isvirtualbalanceenabled ? reserve.virtualbalance : _reservetoken.balanceof(this);
    }

    
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public view returns (uint256, uint256) {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return getpurchasereturn(_fromtoken, _amount);
        else if (_fromtoken == token)
            return getsalereturn(_totoken, _amount);

        
        return getcrossreservereturn(_fromtoken, _totoken, _amount);
    }

    
    function getpurchasereturn(ierc20token _reservetoken, uint256 _depositamount)
        public
        view
        active
        validreserve(_reservetoken)
        returns (uint256, uint256)
    {
        reserve storage reserve = reserves[_reservetoken];
        require(reserve.issaleenabled); 

        uint256 tokensupply = token.totalsupply();
        uint256 reservebalance = _reservetoken.balanceof(this);
        ibancorformula formula = ibancorformula(addressof(bancor_formula));
        uint256 amount = formula.calculatepurchasereturn(tokensupply, reservebalance, reserve.ratio, _depositamount);
        uint256 finalamount = getfinalamount(amount, 1);

        
        return (finalamount, amount  finalamount);
    }

    
    function getsalereturn(ierc20token _reservetoken, uint256 _sellamount)
        public
        view
        active
        validreserve(_reservetoken)
        returns (uint256, uint256)
    {
        reserve storage reserve = reserves[_reservetoken];
        uint256 tokensupply = token.totalsupply();
        uint256 reservebalance = _reservetoken.balanceof(this);
        ibancorformula formula = ibancorformula(addressof(bancor_formula));
        uint256 amount = formula.calculatesalereturn(tokensupply, reservebalance, reserve.ratio, _sellamount);
        uint256 finalamount = getfinalamount(amount, 1);

        
        return (finalamount, amount  finalamount);
    }

    
    function getcrossreservereturn(ierc20token _fromreservetoken, ierc20token _toreservetoken, uint256 _amount)
        public
        view
        active
        validreserve(_fromreservetoken)
        validreserve(_toreservetoken)
        returns (uint256, uint256)
    {
        reserve storage fromreserve = reserves[_fromreservetoken];
        reserve storage toreserve = reserves[_toreservetoken];
        require(fromreserve.issaleenabled); 

        ibancorformula formula = ibancorformula(addressof(bancor_formula));
        uint256 amount = formula.calculatecrossreservereturn(
            getreservebalance(_fromreservetoken), 
            fromreserve.ratio, 
            getreservebalance(_toreservetoken), 
            toreserve.ratio, 
            _amount);
        uint256 finalamount = getfinalamount(amount, 2);

        
        
        return (finalamount, amount  finalamount);
    }

    
    function convertinternal(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn)
        public
        only(bancor_network)
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

        
        (amount, feeamount) = getcrossreservereturn(_fromtoken, _totoken, _amount);
        
        require(amount != 0 && amount >= _minreturn);

        
        reserve storage fromreserve = reserves[_fromtoken];
        if (fromreserve.isvirtualbalanceenabled)
            fromreserve.virtualbalance = fromreserve.virtualbalance.add(_amount);

        
        reserve storage toreserve = reserves[_totoken];
        if (toreserve.isvirtualbalanceenabled)
            toreserve.virtualbalance = toreserve.virtualbalance.sub(amount);

        
        uint256 toreservebalance = getreservebalance(_totoken);
        assert(amount < toreservebalance);

        
        ensuretransferfrom(_fromtoken, msg.sender, this, _amount);
        
        
        ensuretransferfrom(_totoken, this, msg.sender, amount);

        
        
        dispatchconversionevent(_fromtoken, _totoken, _amount, amount, feeamount);

        
        emit pricedataupdate(_fromtoken, token.totalsupply(), _fromtoken.balanceof(this), fromreserve.ratio);
        emit pricedataupdate(_totoken, token.totalsupply(), _totoken.balanceof(this), toreserve.ratio);
        return amount;
    }

    
    function buy(ierc20token _reservetoken, uint256 _depositamount, uint256 _minreturn) internal returns (uint256) {
        uint256 amount;
        uint256 feeamount;
        (amount, feeamount) = getpurchasereturn(_reservetoken, _depositamount);
        
        require(amount != 0 && amount >= _minreturn);

        
        reserve storage reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = reserve.virtualbalance.add(_depositamount);

        
        ensuretransferfrom(_reservetoken, msg.sender, this, _depositamount);
        
        token.issue(msg.sender, amount);

        
        dispatchconversionevent(_reservetoken, token, _depositamount, amount, feeamount);

        
        emit pricedataupdate(_reservetoken, token.totalsupply(), _reservetoken.balanceof(this), reserve.ratio);
        return amount;
    }

    
    function sell(ierc20token _reservetoken, uint256 _sellamount, uint256 _minreturn) internal returns (uint256) {
        require(_sellamount <= token.balanceof(msg.sender)); 
        uint256 amount;
        uint256 feeamount;
        (amount, feeamount) = getsalereturn(_reservetoken, _sellamount);
        
        require(amount != 0 && amount >= _minreturn);

        
        uint256 tokensupply = token.totalsupply();
        uint256 reservebalance = _reservetoken.balanceof(this);
        assert(amount < reservebalance || (amount == reservebalance && _sellamount == tokensupply));

        
        reserve storage reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = reserve.virtualbalance.sub(amount);

        
        token.destroy(msg.sender, _sellamount);
        
        ensuretransferfrom(_reservetoken, this, msg.sender, amount);

        
        dispatchconversionevent(token, _reservetoken, _sellamount, amount, feeamount);

        
        emit pricedataupdate(_reservetoken, token.totalsupply(), _reservetoken.balanceof(this), reserve.ratio);
        return amount;
    }

    
    function convert2(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn, address _affiliateaccount, uint256 _affiliatefee) public returns (uint256) {
        ierc20token[] memory path = new ierc20token[](3);
        (path[0], path[1], path[2]) = (_fromtoken, token, _totoken);
        return quickconvert2(path, _amount, _minreturn, _affiliateaccount, _affiliatefee);
    }

    
    function quickconvert2(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _affiliateaccount, uint256 _affiliatefee)
        public
        payable
        returns (uint256)
    {
        return quickconvertprioritized2(_path, _amount, _minreturn, getsignature(0x0, 0x0, 0x0, 0x0, 0x0), _affiliateaccount, _affiliatefee);
    }

    
    function quickconvertprioritized2(ierc20token[] _path, uint256 _amount, uint256 _minreturn, uint256[] memory _signature, address _affiliateaccount, uint256 _affiliatefee)
        public
        payable
        returns (uint256)
    {
        require(_signature.length == 0 || _signature[0] == _amount);

        ibancornetwork bancornetwork = ibancornetwork(addressof(bancor_network));

        
        
        if (msg.value == 0) {
            
            
            
            if (_path[0] == token) {
                token.destroy(msg.sender, _amount); 
                token.issue(bancornetwork, _amount); 
            } else {
                
                ensuretransferfrom(_path[0], msg.sender, bancornetwork, _amount);
            }
        }

        
        return bancornetwork.convertforprioritized4.value(msg.value)(_path, _amount, _minreturn, msg.sender, _signature, _affiliateaccount, _affiliatefee);
    }

    
    function completexconversion2(
        ierc20token[] _path,
        uint256 _minreturn,
        uint256 _conversionid,
        uint256[] memory _signature
    )
        public
        returns (uint256)
    {
        
        require(_signature.length == 0 || _signature[0] == _conversionid);

        ibancorx bancorx = ibancorx(addressof(bancor_x));
        ibancornetwork bancornetwork = ibancornetwork(addressof(bancor_network));

        
        require(_path[0] == addressof(bnt_token));

        
        uint256 amount = bancorx.getxtransferamount(_conversionid, msg.sender);

        
        token.destroy(msg.sender, amount);
        token.issue(bancornetwork, amount);

        return bancornetwork.convertforprioritized4(_path, amount, _minreturn, msg.sender, _signature, address(0), 0);
    }

    
    function isadmin() internal view returns (bool) {
        return msg.sender == owner || msg.sender == manager;
    }

    
    function ensuretransferfrom(ierc20token _token, address _from, address _to, uint256 _amount) private {
        iaddresslist addresslist = iaddresslist(addressof(non_standard_token_registry));
        bool transferfromthis = _from == address(this);
        if (addresslist.listedaddresses(_token)) {
            uint256 prevbalance = _token.balanceof(_to);
            
            if (transferfromthis)
                inonstandarderc20(_token).transfer(_to, _amount);
            else
                inonstandarderc20(_token).transferfrom(_from, _to, _amount);
            uint256 postbalance = _token.balanceof(_to);
            assert(postbalance > prevbalance);
        } else {
            
            if (transferfromthis)
                assert(_token.transfer(_to, _amount));
            else
                assert(_token.transferfrom(_from, _to, _amount));
        }
    }

    
    function fund(uint256 _amount)
        public
        conversionsallowed
        multiplereservesonly
    {
        uint256 supply = token.totalsupply();
        ibancorformula formula = ibancorformula(addressof(bancor_formula));

        
        
        ierc20token reservetoken;
        uint256 reservebalance;
        uint256 reserveamount;
        for (uint16 i = 0; i < reservetokens.length; i++) {
            reservetoken = reservetokens[i];
            reservebalance = reservetoken.balanceof(this);
            reserveamount = formula.calculatefundcost(supply, reservebalance, totalreserveratio, _amount);

            
            reserve storage reserve = reserves[reservetoken];
            if (reserve.isvirtualbalanceenabled)
                reserve.virtualbalance = reserve.virtualbalance.add(reserveamount);

            
            ensuretransferfrom(reservetoken, msg.sender, this, reserveamount);

            
            emit pricedataupdate(reservetoken, supply + _amount, reservebalance + reserveamount, reserve.ratio);
        }

        
        token.issue(msg.sender, _amount);
    }

    
    function liquidate(uint256 _amount)
        public
        multiplereservesonly
    {
        uint256 supply = token.totalsupply();
        ibancorformula formula = ibancorformula(addressof(bancor_formula));

        
        token.destroy(msg.sender, _amount);

        
        
        ierc20token reservetoken;
        uint256 reservebalance;
        uint256 reserveamount;
        for (uint16 i = 0; i < reservetokens.length; i++) {
            reservetoken = reservetokens[i];
            reservebalance = reservetoken.balanceof(this);
            reserveamount = formula.calculateliquidatereturn(supply, reservebalance, totalreserveratio, _amount);

            
            reserve storage reserve = reserves[reservetoken];
            if (reserve.isvirtualbalanceenabled)
                reserve.virtualbalance = reserve.virtualbalance.sub(reserveamount);

            
            ensuretransferfrom(reservetoken, this, msg.sender, reserveamount);

            
            emit pricedataupdate(reservetoken, supply  _amount, reservebalance  reserveamount, reserve.ratio);
        }
    }

    
    function dispatchconversionevent(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _returnamount, uint256 _feeamount) private {
        
        
        
        
        assert(_feeamount < 2 ** 255);
        emit conversion(_fromtoken, _totoken, msg.sender, _amount, _returnamount, int256(_feeamount));
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

    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return convertinternal(_fromtoken, _totoken, _amount, _minreturn);
    }

    
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256) {
        return convert2(_fromtoken, _totoken, _amount, _minreturn, address(0), 0);
    }

    
    function quickconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public payable returns (uint256) {
        return quickconvert2(_path, _amount, _minreturn, address(0), 0);
    }

    
    function quickconvertprioritized(ierc20token[] _path, uint256 _amount, uint256 _minreturn, uint256 _block, uint8 _v, bytes32 _r, bytes32 _s) public payable returns (uint256) {
        return quickconvertprioritized2(_path, _amount, _minreturn, getsignature(_amount, _block, _v, _r, _s), address(0), 0);
    }

    
    function completexconversion(ierc20token[] _path, uint256 _minreturn, uint256 _conversionid, uint256 _block, uint8 _v, bytes32 _r, bytes32 _s) public returns (uint256) {
        return completexconversion2(_path, _minreturn, _conversionid, getsignature(_conversionid, _block, _v, _r, _s));
    }

    
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool) {
        reserve storage reserve = reserves[_address];
        return(reserve.virtualbalance, reserve.ratio, reserve.isvirtualbalanceenabled, reserve.issaleenabled, reserve.isset);
    }

    
    function connectortokens(uint256 _index) public view returns (ierc20token) {
        return bancorconverter.reservetokens[_index];
    }

    
    function connectortokencount() public view returns (uint16) {
        return reservetokencount();
    }

    
    function addconnector(ierc20token _token, uint32 _weight, bool ) public {
        addreserve(_token, _weight);
    }

    
    function updateconnector(ierc20token _connectortoken, uint32 , bool , uint256 _virtualbalance) public {
        updatereservevirtualbalance(_connectortoken, _virtualbalance);
    }

    
    function disableconnectorsale(ierc20token _connectortoken, bool _disable) public {
        disablereservesale(_connectortoken, _disable);
    }

    
    function getconnectorbalance(ierc20token _connectortoken) public view returns (uint256) {
        return getreservebalance(_connectortoken);
    }

    
    function getcrossconnectorreturn(ierc20token _fromconnectortoken, ierc20token _toconnectortoken, uint256 _amount) public view returns (uint256, uint256) {
        return getcrossreservereturn(_fromconnectortoken, _toconnectortoken, _amount);
    }
}
