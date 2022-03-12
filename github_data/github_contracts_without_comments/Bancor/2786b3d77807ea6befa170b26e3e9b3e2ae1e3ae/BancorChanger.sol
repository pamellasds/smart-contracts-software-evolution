pragma solidity ^0.4.11;
import ;
import ;
import ;
import ;
import ;




contract bancorchanger is itokenchanger, smarttokencontroller, safemath {
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
    mapping (address => reserve) public reserves;   
    uint8 private totalreserveratio = 0;            

    
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _trader, uint256 _amount, uint256 _return);

    
    function bancorchanger(ismarttoken _token, ibancorformula _formula, ierc20token _reservetoken, uint8 _reserveratio)
        smarttokencontroller(_token)
        validaddress(_formula)
    {
        formula = _formula;

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

    
    modifier validreserveratio(uint8 _ratio) {
        require(_ratio > 0 && _ratio <= 100);
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
        reserve reserve = reserves[_reservetoken];
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
        reserve reserve = reserves[_reservetoken];
        return reserve.isvirtualbalanceenabled ? reserve.virtualbalance : _reservetoken.balanceof(this);
    }

    
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public {
        require(_to != address(token)); 
        super.withdrawtokens(_token, _to, _amount);

        if (!reserves[_token].isset)
            return;

        
        reserve reserve = reserves[_token];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safesub(reserve.virtualbalance, _amount);
    }

    
    function getreturn(address _fromtoken, address _totoken, uint256 _amount)
        public
        constant
        validtoken(_fromtoken)
        validtoken(_totoken)
        returns (uint256 amount)
    {
        require(_fromtoken != _totoken); 
        ierc20token fromtoken = ierc20token(_fromtoken);
        ierc20token totoken = ierc20token(_totoken);

        
        if (totoken == token)
            return getpurchasereturn(fromtoken, _amount);
        else if (fromtoken == token)
            return getsalereturn(totoken, _amount);

        
        uint256 purchasereturnamount = getpurchasereturn(fromtoken, _amount);
        return getsalereturn(totoken, purchasereturnamount, safeadd(token.totalsupply(), purchasereturnamount));
    }

    
    function getpurchasereturn(ierc20token _reservetoken, uint256 _depositamount)
        public
        constant
        active
        validreserve(_reservetoken)
        validamount(_depositamount)
        returns (uint256 amount)
    {
        reserve reserve = reserves[_reservetoken];
        require(reserve.ispurchaseenabled); 

        uint256 tokensupply = token.totalsupply();
        uint256 reservebalance = getreservebalance(_reservetoken);
        return formula.calculatepurchasereturn(tokensupply, reservebalance, reserve.ratio, _depositamount);
    }

    
    function getsalereturn(ierc20token _reservetoken, uint256 _sellamount) public constant returns (uint256 amount) {
        return getsalereturn(_reservetoken, _sellamount, token.totalsupply());
    }

    
    function change(address _fromtoken, address _totoken, uint256 _amount, uint256 _minreturn)
        public
        validtoken(_fromtoken)
        validtoken(_totoken)
        returns (uint256 amount)
    {
        require(_fromtoken != _totoken); 
        ierc20token fromtoken = ierc20token(_fromtoken);
        ierc20token totoken = ierc20token(_totoken);

        
        if (totoken == token)
            return buy(fromtoken, _amount, _minreturn);
        else if (fromtoken == token)
            return sell(totoken, _amount, _minreturn);

        
        uint256 purchaseamount = buy(fromtoken, _amount, 0);
        return sell(totoken, purchaseamount, _minreturn);
    }

    
    function buy(ierc20token _reservetoken, uint256 _depositamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getpurchasereturn(_reservetoken, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 

        
        reserve reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safeadd(reserve.virtualbalance, _depositamount);

        assert(_reservetoken.transferfrom(msg.sender, this, _depositamount)); 
        token.issue(msg.sender, amount); 

        change(_reservetoken, token, msg.sender, _depositamount, amount);
        return amount;
    }

    
    function sell(ierc20token _reservetoken, uint256 _sellamount, uint256 _minreturn) public returns (uint256 amount) {
        require(_sellamount <= token.balanceof(msg.sender)); 

        amount = getsalereturn(_reservetoken, _sellamount);
        assert(amount != 0 && amount >= _minreturn); 

        uint256 reservebalance = getreservebalance(_reservetoken);
        assert(amount <= reservebalance); 

        uint256 tokensupply = token.totalsupply();
        assert(amount < reservebalance || _sellamount == tokensupply); 
        token.destroy(msg.sender, _sellamount); 
        assert(_reservetoken.transfer(msg.sender, amount)); 
                                                           

        
        reserve reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safesub(reserve.virtualbalance, amount);

        change(token, _reservetoken, msg.sender, _sellamount, amount);
        return amount;
    }

    
    function getsalereturn(ierc20token _reservetoken, uint256 _sellamount, uint256 _totalsupply)
        private
        constant
        active
        validreserve(_reservetoken)
        validamount(_sellamount)
        validamount(_totalsupply)
        returns (uint256 amount)
    {
        reserve reserve = reserves[_reservetoken];
        uint256 reservebalance = getreservebalance(_reservetoken);
        return formula.calculatesalereturn(_totalsupply, reservebalance, reserve.ratio, _sellamount);
    }

    
    function() {
        assert(false);
    }
}
