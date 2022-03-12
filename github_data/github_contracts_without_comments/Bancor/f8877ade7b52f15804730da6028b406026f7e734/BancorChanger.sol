pragma solidity ^0.4.11;
import ;
import ;
import ;
import ;
import ;
import ;
import ;




contract bancorchanger is itokenchanger, smarttokencontroller, managed {
    uint32 private constant max_crr = 1000000;
    uint32 private constant max_change_fee = 1000000;

    struct reserve {
        uint256 virtualbalance;         
        uint32 ratio;                   
        bool isvirtualbalanceenabled;   
        bool ispurchaseenabled;         
        bool isset;                     
    }

    string public version = ;
    string public changertype = ;

    ibancorformula public formula;                  
    address[] public reservetokens;                 
    address[] public quickbuypath;                  
    mapping (address => reserve) public reserves;   
    uint32 private totalreserveratio = 0;           
    uint32 public maxchangefee = 0;                 
    uint32 public changefee = 0;                    
    bool public changingenabled = true;             

    
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _trader, uint256 _amount, uint256 _return,
                 uint256 _currentpricen, uint256 _currentpriced);

    
    function bancorchanger(ismarttoken _token, ibancorformula _formula, uint32 _maxchangefee, ierc20token _reservetoken, uint32 _reserveratio)
        smarttokencontroller(_token)
        validaddress(_formula)
        validmaxchangefee(_maxchangefee)
    {
        formula = _formula;
        maxchangefee = _maxchangefee;

        if (address(_reservetoken) != 0x0)
            addreserve(_reservetoken, _reserveratio, false);
    }

    
    modifier validreserve(address _address) {
        require(reserves[_address].isset);
        _;
    }

    
    modifier validtoken(address _address) {
        require(_address == address(token) || reserves[_address].isset);
        _;
    }

    
    modifier validmaxchangefee(uint32 _changefee) {
        require(_changefee >= 0 && _changefee <= max_change_fee);
        _;
    }

    
    modifier validchangefee(uint32 _changefee) {
        require(_changefee >= 0 && _changefee <= maxchangefee);
        _;
    }

    
    modifier validreserveratio(uint32 _ratio) {
        require(_ratio > 0 && _ratio <= max_crr);
        _;
    }

    
    modifier validchangepath(address[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

    
    modifier changingallowed {
        assert(changingenabled);
        _;
    }

    
    function reservetokencount() public constant returns (uint16 count) {
        return uint16(reservetokens.length);
    }

    
    function changeabletokencount() public constant returns (uint16 count) {
        return reservetokencount() + 1;
    }

    
    function changeabletoken(uint16 _tokenindex) public constant returns (address tokenaddress) {
        if (_tokenindex == 0)
            return token;
        return reservetokens[_tokenindex  1];
    }

    
    function setformula(ibancorformula _formula)
        public
        owneronly
        validaddress(_formula)
        notthis(_formula)
    {
        formula = _formula;
    }

    
    function setquickbuypath(address[] _path)
        public
        owneronly
        validchangepath(_path)
    {
        quickbuypath = _path;
    }

    
    function clearquickbuypath() public owneronly {
        quickbuypath.length = 0;
    }

    
    function getquickbuypathlength() public constant returns (uint256 length) {
        return quickbuypath.length;
    }

    
    function getquickbuyethertokenaddress() public constant returns (address ethertoken) {
        if (quickbuypath.length == 0)
            return 0x0;
        return quickbuypath[0];
    }

    
    function disablechanging(bool _disable) public manageronly {
        changingenabled = !_disable;
    }

    
    function setchangefee(uint32 _changefee)
        public
        manageronly
        validchangefee(_changefee)
    {
        changefee = _changefee;
    }

    
    function getchangefeeamount(uint256 _amount) public constant returns (uint256 feeamount) {
        return safemul(_amount, changefee) / max_change_fee;
    }

    
    function addreserve(ierc20token _token, uint32 _ratio, bool _enablevirtualbalance)
        public
        owneronly
        inactive
        validaddress(_token)
        notthis(_token)
        validreserveratio(_ratio)
    {
        require(_token != address(token) && !reserves[_token].isset && totalreserveratio + _ratio <= max_crr); 

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
        returns (uint256 balance)
    {
        reserve storage reserve = reserves[_reservetoken];
        return reserve.isvirtualbalanceenabled ? reserve.virtualbalance : _reservetoken.balanceof(this);
    }

    
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public constant returns (uint256 amount) {
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
        returns (uint256 amount)
    {
        reserve storage reserve = reserves[_reservetoken];
        require(reserve.ispurchaseenabled); 

        uint256 tokensupply = token.totalsupply();
        uint256 reservebalance = getreservebalance(_reservetoken);
        amount = formula.calculatepurchasereturn(tokensupply, reservebalance, reserve.ratio, _depositamount);

        
        uint256 feeamount = getchangefeeamount(amount);
        return safesub(amount, feeamount);
    }

    
    function getsalereturn(ierc20token _reservetoken, uint256 _sellamount) public constant returns (uint256 amount) {
        return getsalereturn(_reservetoken, _sellamount, token.totalsupply());
    }

    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256 amount) {
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
        changingallowed
        greaterthanzero(_minreturn)
        returns (uint256 amount)
    {
        amount = getpurchasereturn(_reservetoken, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 

        
        reserve storage reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safeadd(reserve.virtualbalance, _depositamount);

        assert(_reservetoken.transferfrom(msg.sender, this, _depositamount)); 
        token.issue(msg.sender, amount); 

        
        
        
        uint256 reserveamount = safemul(getreservebalance(_reservetoken), max_crr);
        uint256 tokenamount = safemul(token.totalsupply(), reserve.ratio);
        change(_reservetoken, token, msg.sender, _depositamount, amount, reserveamount, tokenamount);
        return amount;
    }

    
    function sell(ierc20token _reservetoken, uint256 _sellamount, uint256 _minreturn)
        public
        changingallowed
        greaterthanzero(_minreturn)
        returns (uint256 amount)
    {
        require(_sellamount <= token.balanceof(msg.sender)); 

        amount = getsalereturn(_reservetoken, _sellamount);
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
        change(token, _reservetoken, msg.sender, _sellamount, amount, tokenamount, reserveamount);
        return amount;
    }

    
    function quickchange(uint256 _amount, address[] _path, uint256 _minreturn)
        public
        validchangepath(_path)
        returns (uint256 amount)
    {
        
        
        
        ierc20token fromtoken = ierc20token(_path[0]);
        require(fromtoken != _path[1] || fromtoken == address(token));

        
        
        
        if (fromtoken == address(token)) {
            token.destroy(msg.sender, _amount); 
            token.issue(this, _amount); 
        }
        
        else {
            assert(fromtoken.transferfrom(msg.sender, this, _amount));
        }

        ismarttoken smarttoken;
        ierc20token totoken;
        bancorchanger changer;

        
        for (uint8 i = 1; i < _path.length; i += 2) {
            smarttoken = ismarttoken(_path[i]);
            totoken = ierc20token(_path[i + 1]);
            changer = bancorchanger(smarttoken.owner());

            
            if (smarttoken != fromtoken)
                ensureallowance(fromtoken, changer, _amount);

            
            _amount = changer.change(fromtoken, totoken, _amount, i == _path.length  2 ? _minreturn : 1);
            fromtoken = totoken;
        }

        
        
        if (changer.getquickbuyethertokenaddress() == address(totoken)) {
            iethertoken ethertoken = iethertoken(totoken);
            ethertoken.withdraw(_amount);
            msg.sender.transfer(_amount);
            return;
        }

        
        assert(totoken.transfer(msg.sender, _amount));
        amount = _amount;
    }

    
    function quickbuy(uint256 _minreturn) public payable returns (uint256 amount) {
        
        assert(quickbuypath.length > 0);
        
        iethertoken ethertoken = iethertoken(quickbuypath[0]);
        
        ethertoken.deposit.value(msg.value)();
        
        ismarttoken smarttoken = ismarttoken(quickbuypath[1]);
        bancorchanger changer = bancorchanger(smarttoken.owner());
        
        ensureallowance(ethertoken, changer, msg.value);
        
        uint256 returnamount = changer.quickchange(msg.value, quickbuypath, _minreturn);
        
        assert(token.transfer(msg.sender, returnamount));
        return returnamount;
    }

    
    function getsalereturn(ierc20token _reservetoken, uint256 _sellamount, uint256 _totalsupply)
        private
        constant
        active
        validreserve(_reservetoken)
        greaterthanzero(_totalsupply)
        returns (uint256 amount)
    {
        reserve storage reserve = reserves[_reservetoken];
        uint256 reservebalance = getreservebalance(_reservetoken);
        amount = formula.calculatesalereturn(_totalsupply, reservebalance, reserve.ratio, _sellamount);

        
        uint256 feeamount = getchangefeeamount(amount);
        return safesub(amount, feeamount);
    }

    
    function ensureallowance(ierc20token _token, address _spender, uint256 _value) private {
        
        if (_token.allowance(this, _spender) >= _value)
            return;

        
        if (_token.allowance(this, _spender) != 0)
            assert(_token.approve(_spender, 0));

        
        assert(_token.approve(_spender, _value));
    }

    
    function() payable {
        quickbuy(1);
    }
}
