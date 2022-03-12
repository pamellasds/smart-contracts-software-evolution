pragma solidity ^0.4.11;
import ;
import ;
import ;
import ;
import ;
import ;
import ;




contract bancorchanger is itokenchanger, smarttokencontroller, managed {
    struct reserve {
        uint256 virtualbalance;         
        uint8 ratio;                    
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
    uint8 private totalreserveratio = 0;            
    uint16 public maxchangefeepercentage = 0;       
    uint16 public changefeepercentage = 0;          
    bool public changingenabled = true;             

    
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _trader, uint256 _amount, uint256 _return);
    
    event pricechange(address indexed _token1, address indexed _token2, uint256 _token1amount, uint256 _token2amount);

    
    function bancorchanger(ismarttoken _token, ibancorformula _formula, uint16 _maxchangefeepercentage, ierc20token _reservetoken, uint256 _reserveratio)
        smarttokencontroller(_token)
        validaddress(_formula)
        validmaxchangefeepercentage(_maxchangefeepercentage)
    {
        formula = _formula;
        maxchangefeepercentage = _maxchangefeepercentage;

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

    
    modifier validmaxchangefeepercentage(uint16 _changefeepercentage) {
        require(_changefeepercentage >= 0 && _changefeepercentage <= 10000);
        _;
    }

    
    modifier validchangefeepercentage(uint16 _changefeepercentage) {
        require(_changefeepercentage >= 0 && _changefeepercentage <= maxchangefeepercentage);
        _;
    }

    
    modifier validreserveratio(uint8 _ratio) {
        require(_ratio > 0 && _ratio <= 100);
        _;
    }

    
    modifier validchangepath(address[] _path) {
        require(_path.length > 1 && _path.length <= 30 && _path.length % 3 == 0);
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
        manageronly
        validchangepath(_path)
    {
        quickbuypath = _path;
    }

    
    function getquickbuypathlength() public constant returns (uint256 length) {
        return quickbuypath.length;
    }

    
    function disablechanging(bool _disable) public manageronly {
        changingenabled = !_disable;
    }

    
    function setchangefeepercentage(uint16 _changefeepercentage)
        public
        manageronly
        validchangefeepercentage(_changefeepercentage)
    {
        changefeepercentage = _changefeepercentage;
    }

    
    function getchangefee(uint256 _amount) public constant returns (uint256 fee) {
        return safemul(_amount, changefeepercentage) / 10000;
    }

    
    function addreserve(ierc20token _token, uint8 _ratio, bool _enablevirtualbalance)
        public
        owneronly
        inactive
        validaddress(_token)
        notthis(_token)
        validreserveratio(_ratio)
    {
        require(_token != address(token) && !reserves[_token].isset && totalreserveratio + _ratio <= 100); 

        reserves[_token].virtualbalance = 0;
        reserves[_token].ratio = _ratio;
        reserves[_token].isvirtualbalanceenabled = _enablevirtualbalance;
        reserves[_token].ispurchaseenabled = true;
        reserves[_token].isset = true;
        reservetokens.push(_token);
        totalreserveratio += _ratio;
    }

    
    function updatereserve(ierc20token _reservetoken, uint8 _ratio, bool _enablevirtualbalance, uint256 _virtualbalance)
        public
        owneronly
        validreserve(_reservetoken)
        validreserveratio(_ratio)
    {
        reserve storage reserve = reserves[_reservetoken];
        require(totalreserveratio  reserve.ratio + _ratio <= 100); 

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

        
        uint256 fee = getchangefee(amount);
        return safesub(amount, fee);
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

        change(_reservetoken, token, msg.sender, _depositamount, amount);

        
        
        
        pricechange(_reservetoken, token, safemul(getreservebalance(_reservetoken), 100), safemul(token.totalsupply(), reserve.ratio));
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
                                                            
        change(token, _reservetoken, msg.sender, _sellamount, amount);

        
        
        
        pricechange(token, _reservetoken, safemul(token.totalsupply(), reserve.ratio), safemul(getreservebalance(_reservetoken), 100));
        return amount;
    }

    
    function quickchange(uint256 _amount, address[] _path, uint256 _minreturn)
        public
        validchangepath(_path)
        returns (uint256 amount)
    {
        
        
        
        
        require(_path[0] == _path[2] || _path[0] == address(token));

        ismarttoken smarttoken = ismarttoken(_path[0]);
        ierc20token fromtoken;
        ierc20token totoken;
        bancorchanger changer;

        
        
        if (smarttoken == _path[2]) {
            fromtoken = ierc20token(_path[1]);
            assert(fromtoken.transferfrom(msg.sender, this, _amount));
        }
        
        else {
            token.destroy(msg.sender, _amount); 
            token.issue(this, _amount); 
        }

        
        for (uint8 i = 0; i < _path.length; i += 3) {
            smarttoken = ismarttoken(_path[i]);
            fromtoken = ierc20token(_path[i + 1]);
            totoken = ierc20token(_path[i + 2]);
            changer = bancorchanger(smarttoken.owner());

            
            if (smarttoken == totoken)
                ensureallowance(fromtoken, changer, _amount);

            
            _amount = changer.change(fromtoken, totoken, _amount, i == _path.length  3 ? _minreturn : 1);
        }

        
        
        
        if (changer.getquickbuypathlength() > 0 && changer.quickbuypath(1) == address(totoken)) {
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
        
        iethertoken ethertoken = iethertoken(quickbuypath[1]);
        
        ethertoken.deposit.value(msg.value)();
        
        ensureallowance(ethertoken, this, msg.value);
        
        bancorchanger changer = bancorchanger(quickbuypath[0]);
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

        
        uint256 fee = getchangefee(amount);
        return safesub(amount, fee);
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
