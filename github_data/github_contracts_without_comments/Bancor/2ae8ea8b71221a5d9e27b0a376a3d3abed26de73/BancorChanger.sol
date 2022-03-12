pragma solidity ^0.4.10;
import ;
import ;
import ;
import ;





contract bancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _depositamount) public constant returns (uint256 amount);
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256 amount);
}


contract bancorchanger is owned, safemath, tokenchangerinterface {
    struct reserve {
        uint256 virtualbalance;         
        uint8 ratio;                    
        bool isvirtualbalanceenabled;   
        bool isenabled;                 
        bool isset;                     
    }

    string public version = ;
    string public changertype = ;

    smarttokeninterface public token;               
    bancorformula public formula;                   
    address[] public reservetokens;                 
    mapping (address => reserve) public reserves;   
    uint8 private totalreserveratio = 0;            

    
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _trader, uint256 _amount, uint256 _return);

    
    function bancorchanger(address _token, address _formula, address _reservetoken, uint8 _reserveratio)
        validaddress(_token)
        validaddress(_formula)
    {
        token = smarttokeninterface(_token);
        formula = bancorformula(_formula);

        if (_reservetoken != 0x0)
            addreserve(_reservetoken, _reserveratio, false);
    }

    
    modifier validaddress(address _address) {
        require(_address != 0x0);
        _;
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

    
    modifier validamount(uint256 _value) {
        require(_value > 0);
        _;
    }

    
    modifier active() {
        assert(token.changer() == address(this));
        _;
    }

    
    modifier inactive() {
        assert(token.changer() != address(this));
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

    
    function addreserve(address _token, uint8 _ratio, bool _enablevirtualbalance)
        public
        owneronly
        inactive
        validaddress(_token)
        validreserveratio(_ratio)
    {
        require(_token != address(this) && _token != address(token) && !reserves[_token].isset && totalreserveratio + _ratio <= 100); 

        reserves[_token].virtualbalance = 0;
        reserves[_token].ratio = _ratio;
        reserves[_token].isvirtualbalanceenabled = _enablevirtualbalance;
        reserves[_token].isenabled = true;
        reserves[_token].isset = true;
        reservetokens.push(_token);
        totalreserveratio += _ratio;
    }

    
    function updatereserve(address _reservetoken, uint8 _ratio, bool _enablevirtualbalance, uint256 _virtualbalance)
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

    
    function disablereserve(address _reservetoken, bool _disable)
        public
        owneronly
        validreserve(_reservetoken)
    {
        reserves[_reservetoken].isenabled = !_disable;
    }

    
    function getreservebalance(address _reservetoken)
        public
        constant
        validreserve(_reservetoken)
        returns (uint256 balance)
    {
        reserve reserve = reserves[_reservetoken];
        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        return reserve.isvirtualbalanceenabled ? reserve.virtualbalance : reservetoken.balanceof(this);
    }

    
    function issuetokens(address _to, uint256 _amount) public owneronly {
        token.issue(_to, _amount);
    }

    
    function destroytokens(address _from, uint256 _amount) public owneronly {
        token.destroy(_from, _amount);
    }

    
    function withdraw(address _reservetoken, address _to, uint256 _amount)
        public
        owneronly
        validreserve(_reservetoken)
        validaddress(_to)
        validamount(_amount)
    {
        require(_to != address(this) && _to != address(token)); 

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        assert(reservetoken.transfer(_to, _amount));

        
        reserve reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safesub(reserve.virtualbalance, _amount);
    }

    
    function settokenchanger(address _changer) public owneronly {
        require(_changer != address(this) && _changer != address(token)); 
        token.setchanger(_changer);
    }

    
    function getreturn(address _fromtoken, address _totoken, uint256 _amount)
        public
        constant
        validtoken(_fromtoken)
        validtoken(_totoken)
        returns (uint256 amount)
    {
        require(_fromtoken != _totoken); 

        
        address tokenaddress = address(token);
        if (_totoken == tokenaddress)
            return getpurchasereturn(_fromtoken, _amount);
        else if (_fromtoken == tokenaddress)
            return getsalereturn(_totoken, _amount);

        
        uint256 purchasereturnamount = getpurchasereturn(_fromtoken, _amount);
        return getsalereturn(_totoken, purchasereturnamount, safeadd(token.totalsupply(), purchasereturnamount));
    }

    
    function getpurchasereturn(address _reservetoken, uint256 _depositamount)
        public
        constant
        active
        validreserve(_reservetoken)
        validamount(_depositamount)
        returns (uint256 amount)
    {
        reserve reserve = reserves[_reservetoken];
        require(reserve.isenabled); 

        uint256 tokensupply = token.totalsupply();
        uint256 reservebalance = getreservebalance(_reservetoken);
        return formula.calculatepurchasereturn(tokensupply, reservebalance, reserve.ratio, _depositamount);
    }

    
    function getsalereturn(address _reservetoken, uint256 _sellamount) public constant returns (uint256 amount) {
        return getsalereturn(_reservetoken, _sellamount, token.totalsupply());
    }

    
    function change(address _fromtoken, address _totoken, uint256 _amount, uint256 _minreturn)
        public
        validtoken(_fromtoken)
        validtoken(_totoken)
        returns (uint256 amount)
    {
        require(_fromtoken != _totoken); 

        
        address tokenaddress = address(token);
        if (_totoken == tokenaddress)
            return buy(_fromtoken, _amount, _minreturn);
        else if (_fromtoken == tokenaddress)
            return sell(_totoken, _amount, _minreturn);

        
        uint256 purchaseamount = buy(_fromtoken, _amount, 0);
        return sell(_totoken, purchaseamount, _minreturn);
    }

    
    function buy(address _reservetoken, uint256 _depositamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getpurchasereturn(_reservetoken, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 

        
        reserve reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safeadd(reserve.virtualbalance, _depositamount);

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        assert(reservetoken.transferfrom(msg.sender, this, _depositamount)); 
        token.issue(msg.sender, amount); 

        change(_reservetoken, token, msg.sender, _depositamount, amount);
        return amount;
    }

    
    function sell(address _reservetoken, uint256 _sellamount, uint256 _minreturn) public returns (uint256 amount) {
        require(_sellamount <= token.balanceof(msg.sender)); 

        amount = getsalereturn(_reservetoken, _sellamount);
        assert(amount != 0 && amount >= _minreturn); 

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        uint256 reservebalance = getreservebalance(_reservetoken);
        assert(amount <= reservebalance); 

        uint256 tokensupply = token.totalsupply();
        assert(amount < reservebalance || _sellamount == tokensupply); 
        token.destroy(msg.sender, _sellamount); 
        assert(reservetoken.transfer(msg.sender, amount)); 
                                                           

        
        reserve reserve = reserves[_reservetoken];
        if (reserve.isvirtualbalanceenabled)
            reserve.virtualbalance = safesub(reserve.virtualbalance, amount);

        
        if (_sellamount == tokensupply)
            token.setchanger(0x0);

        change(token, _reservetoken, msg.sender, _sellamount, amount);
        return amount;
    }

    
    function getsalereturn(address _reservetoken, uint256 _sellamount, uint256 _totalsupply)
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
