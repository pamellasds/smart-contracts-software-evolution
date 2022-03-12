pragma solidity ^0.4.10;
import ;
import ;
import ;
import ;





contract bancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _depositamount) public constant returns (uint256 amount);
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256 amount);
    function newformula() public constant returns (address newformula);
}


contract bancortoken is owned, standardtoken {
    struct reserve {
        uint8 ratio;    
        bool isenabled; 
        bool isset;     
    }

    enum stage { managed, crowdsale, traded }

    uint8 public numdecimalunits = 0;                   
    address public formula = 0x0;                       
    address public events = 0x0;                        
    address public crowdsale = 0x0;                     
    int256 public crowdsaleallowance = 0;               
    stage public stage = stage.managed;                 
    address[] public reservetokens;                     
    mapping (address => reserve) public reserves;       
    uint8 private totalreserveratio = 0;                

    
    event update();
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _changer, uint256 _amount, uint256 _return);

    
    function bancortoken(string _name, string _symbol, uint8 _numdecimalunits, address _formula, address _events)
        standardtoken(_name, _symbol)
    {
        require(bytes(_name).length != 0 && bytes(_symbol).length >= 1 && bytes(_symbol).length <= 6 && _formula != 0x0); 

        numdecimalunits = _numdecimalunits;
        formula = _formula;
        events = _events;
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.newtoken();
    }

    
    modifier managedonly {
        assert(stage == stage.managed);
        _;
    }

    
    modifier tradedonly {
        assert(stage == stage.traded);
        _;
    }

    
    modifier notincrowdsale {
        assert(stage != stage.crowdsale);
        _;
    }

    
    modifier manageronly {
        assert((stage == stage.managed && msg.sender == owner) ||
               (stage == stage.crowdsale && msg.sender == crowdsale)); 
        _;
    }

    function setowner(address _newowner) public owneronly {
        address prevowner = owner;
        super.setowner(_newowner);
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokenownerupdate(prevowner, owner);
    }

    
    function setformula(address _formula) public owneronly returns (bool success) {
        bancorformula formulacontract = bancorformula(formula);
        require(_formula == formulacontract.newformula());
        formula = _formula;
        return true;
    }

    
    function reservetokencount() public constant returns (uint16 count) {
        return uint16(reservetokens.length);
    }

    
    function changeabletokencount() public constant returns (uint16 count) {
        return reservetokencount() + 1;
    }

    
    function changeabletoken(uint16 _tokenindex) public constant returns (address tokenaddress) {
        if (_tokenindex == 0)
            return this;
        return reservetokens[_tokenindex  1];
    }

    
    function addreserve(address _token, uint8 _ratio)
        public
        owneronly
        managedonly
        returns (bool success)
    {
        require(_token != address(this) && !reserves[_token].isset && _ratio > 0 && _ratio <= 100 && totalreserveratio + _ratio <= 100); 

        reserves[_token].ratio = _ratio;
        reserves[_token].isenabled = true;
        reserves[_token].isset = true;
        reservetokens.push(_token);
        totalreserveratio += _ratio;
        dispatchupdate();
        return true;
    }

    
    function issue(address _to, uint256 _amount) public returns (bool success) {
         
        require(_amount != 0);
        
        assert((stage == stage.managed && msg.sender == owner) ||
                stage != stage.managed && msg.sender == crowdsale);
         
        assert(totalsupply + _amount >= totalsupply);
        
        assert(balanceof[_to] + _amount >= balanceof[_to]);
        
        assert(stage == stage.managed || crowdsaleallowance == 1 || _amount <= uint256(crowdsaleallowance));

        totalsupply += _amount;
        balanceof[_to] += _amount;
        if (stage != stage.managed && crowdsaleallowance != 1)
            crowdsaleallowance = int256(_amount);

        dispatchupdate();
        dispatchtransfer(this, _to, _amount);
        return true;
    }

    
    function destroy(address _from, uint256 _amount) public manageronly returns (bool success) {
        require(_amount != 0 && _amount <= balanceof[_from]); 

        totalsupply = _amount;
        balanceof[_from] = _amount;
        dispatchupdate();
        dispatchtransfer(_from, this, _amount);
        return true;
    }

    
    function withdraw(address _reservetoken, address _to, uint256 _amount) public manageronly returns (bool success) {
        require(reserves[_reservetoken].isset && _amount != 0); 
        standardtokeninterface reservetoken = standardtokeninterface(_reservetoken);
        return reservetoken.transfer(_to, _amount);
    }

    
    function disablereserve(address _reservetoken, bool _disable) public owneronly {
        require(reserves[_reservetoken].isset); 
        reserves[_reservetoken].isenabled = !_disable;
        dispatchupdate();
    }

    
    function startcrowdsale(address _crowdsale, int256 _allowance)
        public
        owneronly
        managedonly
        returns (bool success)
    {
        require(_crowdsale != 0x0 && _allowance != 0); 
        assert(reservetokens.length != 0); 

        crowdsale = _crowdsale;
        crowdsaleallowance = _allowance;
        stage = stage.crowdsale;
        dispatchupdate();
        return true;
    }

    
    function starttrading() public manageronly returns (bool success) {
        assert(totalsupply != 0); 

        
        for (uint16 i = 0; i < reservetokens.length; ++i) {
            standardtokeninterface reservetoken = standardtokeninterface(reservetokens[i]);
            assert(reservetoken.balanceof(this) != 0);
        }

        stage = stage.traded;
        dispatchupdate();
        return true;
    }

    
    function getreturn(address _fromtoken, address _totoken, uint256 _amount) public constant returns (uint256 amount) {
        require(_fromtoken != _totoken); 
        require(_fromtoken == address(this) || reserves[_fromtoken].isset); 
        require(_totoken == address(this) || reserves[_totoken].isset); 

        
        if (_totoken == address(this))
            return getpurchasereturn(_fromtoken, _amount);
        else if (_fromtoken == address(this))
            return getsalereturn(_totoken, _amount);

        
        uint256 tempamount = getpurchasereturn(_fromtoken, _amount);
        return getsalereturn(_totoken, tempamount);
    }

    
    function change(address _fromtoken, address _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256 amount) {
        require(_fromtoken != _totoken); 
        require(_fromtoken == address(this) || reserves[_fromtoken].isset); 
        require(_totoken == address(this) || reserves[_totoken].isset); 

        
        if (_totoken == address(this))
            return buy(_fromtoken, _amount, _minreturn);
        else if (_fromtoken == address(this))
            return sell(_totoken, _amount, _minreturn);

        
        uint256 tempamount = buy(_fromtoken, _amount, 0);
        return sell(_totoken, tempamount, _minreturn);
    }

    
    function getpurchasereturn(address _reservetoken, uint256 _depositamount)
        public
        constant
        tradedonly
        returns (uint256 amount)
    {
        reserve reserve = reserves[_reservetoken];
        require(reserve.isset && reserve.isenabled && _depositamount != 0); 

        standardtokeninterface reservetoken = standardtokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);

        bancorformula formulacontract = bancorformula(formula);
        return formulacontract.calculatepurchasereturn(totalsupply, reservebalance, reserve.ratio, _depositamount);
    }

    
    function getsalereturn(address _reservetoken, uint256 _sellamount)
        public
        constant
        tradedonly
        returns (uint256 amount)
    {
        reserve reserve = reserves[_reservetoken];
        require(reserve.isset && _sellamount != 0 && _sellamount <= balanceof[msg.sender]); 

        standardtokeninterface reservetoken = standardtokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);

        bancorformula formulacontract = bancorformula(formula);
        return formulacontract.calculatesalereturn(totalsupply, reservebalance, reserve.ratio, _sellamount);
    }

    
    function buy(address _reservetoken, uint256 _depositamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getpurchasereturn(_reservetoken, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 
        assert(totalsupply + amount >= totalsupply); 

        standardtokeninterface reservetoken = standardtokeninterface(_reservetoken);
        assert(reservetoken.transferfrom(msg.sender, this, _depositamount)); 

        totalsupply += amount;
        balanceof[msg.sender] += amount;
        dispatchchange(_reservetoken, this, msg.sender, _depositamount, amount);
        return amount;
    }

    
    function sell(address _reservetoken, uint256 _sellamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getsalereturn(_reservetoken, _sellamount);
        assert(amount != 0 && amount >= _minreturn); 
        
        standardtokeninterface reservetoken = standardtokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);
        assert(amount < reservebalance); 

        totalsupply = _sellamount;
        balanceof[msg.sender] = _sellamount;
        assert(reservetoken.transfer(msg.sender, amount)); 

        
        if (totalsupply == 0) {
            crowdsale = 0x0;
            crowdsaleallowance = 0;
            stage = stage.managed;
        }

        dispatchchange(this, _reservetoken, msg.sender, _sellamount, amount);
        return amount;
    }

    

    
    function transfer(address _to, uint256 _value) public notincrowdsale returns (bool success) {
        super.transfer(_to, _value);

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
        }

        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokentransfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public notincrowdsale returns (bool success) {
        super.transferfrom(_from, _to, _value);

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
        }

        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokentransfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        super.approve(_spender, _value);
        if (events == 0x0)
            return true;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokenapproval(msg.sender, _spender, _value);
        return true;
    }

    

    function dispatchupdate() private {
        update();
        
    }

    function dispatchtransfer(address _from, address _to, uint256 _value) private {
        transfer(_from, _to, _value);
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokentransfer(_from, _to, _value);
    }

    function dispatchchange(address _fromtoken, address _totoken, address _changer, uint256 _amount, uint256 _return) private {
        change(_fromtoken, _totoken, _changer, _amount, _return);
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokenchange(_fromtoken, _totoken, _changer, _amount, _return);
    }

    
    function() {
        assert(false);
    }
}
