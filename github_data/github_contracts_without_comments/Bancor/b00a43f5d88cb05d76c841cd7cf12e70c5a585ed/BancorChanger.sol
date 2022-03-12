pragma solidity ^0.4.10;
import ;
import ;
import ;





contract bancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _depositamount) public constant returns (uint256 amount);
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256 amount);
}


contract bancorchanger is bancoreventsdispatcher, tokenchangerinterface {
    struct reserve {
        uint8 ratio;    
        bool isenabled; 
        bool isset;     
    }

    smarttokeninterface public token;               
    bancorformula public formula;                   
    bool public isactive = false;                   
    address[] public reservetokens;                 
    mapping (address => reserve) public reserves;   
    uint8 private totalreserveratio = 0;            

    
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _trader, uint256 _amount, uint256 _return);

    
    function bancorchanger(address _token, address _formula, address _events)
        bancoreventsdispatcher(_events)
        validaddress(_token)
        validaddress(_formula)
    {
        token = smarttokeninterface(_token);
        formula = bancorformula(_formula);
    }

    
    modifier validaddress(address _address) {
        assert(_address != 0x0);
        _;
    }

    
    modifier validreserve(address _address) {
        assert(reserves[_address].isset);
        _;
    }

    
    modifier validtoken(address _address) {
        assert(_address == address(token) || reserves[_address].isset);
        _;
    }

    
    modifier active() {
        assert(isactive);
        _;
    }

    
    modifier inactive() {
        assert(!isactive);
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

    
    function addreserve(address _token, uint8 _ratio)
        public
        owneronly
        inactive
        validaddress(_token)
        returns (bool success)
    {
        require(_token != address(this) && _token != address(token) && !reserves[_token].isset && _ratio > 0 && _ratio <= 100 && totalreserveratio + _ratio <= 100); 

        reserves[_token].ratio = _ratio;
        reserves[_token].isenabled = true;
        reserves[_token].isset = true;
        reservetokens.push(_token);
        totalreserveratio += _ratio;
        return true;
    }

    
    function issuetoken(address _to, uint256 _amount) public owneronly returns (bool success) {
        return token.issue(_to, _amount);
    }

    
    function destroytoken(address _from, uint256 _amount) public owneronly returns (bool success) {
        return token.destroy(_from, _amount);
    }

    
    function withdraw(address _reservetoken, address _to, uint256 _amount)
        public
        owneronly
        validreserve(_reservetoken)
        validaddress(_to)
        returns (bool success)
    {
        require(_to != address(this) && _amount != 0); 
        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        return reservetoken.transfer(_to, _amount);
    }

    
    function disablereserve(address _reservetoken, bool _disable)
        public
        owneronly
        validreserve(_reservetoken)
    {
        reserves[_reservetoken].isenabled = !_disable;
    }

    
    function settokenchanger(address _changer)
        public
        owneronly
        validaddress(_changer)
        returns (bool success)
    {
        require(_changer != address(this));
        return token.setchanger(_changer);
    }

    
    function activate()
        public
        owneronly
        inactive
        returns (bool success)
    {
        assert(token.totalsupply() != 0 && reservetokens.length > 0); 
        token.disabletransfers(false);
        isactive = true;
        return true;
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

        
        uint256 tempamount = getpurchasereturn(_fromtoken, _amount);
        return getsalereturn(_totoken, tempamount);
    }

    
    function getpurchasereturn(address _reservetoken, uint256 _depositamount)
        public
        constant
        active
        validreserve(_reservetoken)
        returns (uint256 amount)
    {
        reserve reserve = reserves[_reservetoken];
        require(reserve.isenabled && _depositamount != 0); 

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);
        assert(reservebalance != 0); 

        uint256 tokensupply = token.totalsupply();
        return formula.calculatepurchasereturn(tokensupply, reservebalance, reserve.ratio, _depositamount);
    }

    
    function getsalereturn(address _reservetoken, uint256 _sellamount)
        public
        constant
        active
        validreserve(_reservetoken)
        returns (uint256 amount)
    {
        require(_sellamount != 0 && _sellamount <= token.balanceof(msg.sender)); 

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);
        assert(reservebalance != 0); 
        
        uint256 tokensupply = token.totalsupply();
        reserve reserve = reserves[_reservetoken];
        return formula.calculatesalereturn(tokensupply, reservebalance, reserve.ratio, _sellamount);
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

        
        uint256 tempamount = buy(_fromtoken, _amount, 0);
        return sell(_totoken, tempamount, _minreturn);
    }

    
    function buy(address _reservetoken, uint256 _depositamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getpurchasereturn(_reservetoken, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        assert(reservetoken.transferfrom(msg.sender, this, _depositamount)); 

        assert(token.issue(msg.sender, amount)); 
        dispatchchange(_reservetoken, token, msg.sender, _depositamount, amount);
        return amount;
    }

    
    function sell(address _reservetoken, uint256 _sellamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getsalereturn(_reservetoken, _sellamount);
        assert(amount != 0 && amount >= _minreturn); 
        
        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);
        assert(amount <= reservebalance); 

        uint256 tokensupply = token.totalsupply();
        assert(amount < reservebalance || _sellamount == tokensupply); 

        assert(token.destroy(msg.sender, _sellamount)); 
        assert(reservetoken.transfer(msg.sender, amount)); 

        
        if (_sellamount == tokensupply)
            token.setchanger(0x0);

        dispatchchange(this, _reservetoken, msg.sender, _sellamount, amount);
        return amount;
    }

    

    function dispatchchange(address _fromtoken, address _totoken, address _trader, uint256 _amount, uint256 _return) private {
        change(_fromtoken, _totoken, _trader, _amount, _return);

        if (address(events) != 0x0)
            events.tokenchange(_fromtoken, _totoken, _trader, _amount, _return);
    }

    
    function() {
        assert(false);
    }
}
