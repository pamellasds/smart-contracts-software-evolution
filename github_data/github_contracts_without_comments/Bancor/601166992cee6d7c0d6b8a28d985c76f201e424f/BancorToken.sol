pragma solidity ^0.4.8;
import ;
import ;





contract reservetoken { 
    function balanceof(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract bancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _depositamount) public constant returns (uint256 amount);
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256 amount);
    function newformula() public constant returns (address newformula);
}

contract bancorevents {
    function newtoken() public;
    function tokenupdate() public;
    function newtokenowner(address _prevowner, address _newowner) public;
    function tokentransfer(address _from, address _to, uint256 _value) public;
    function tokenapproval(address _owner, address _spender, uint256 _value) public;
    function tokenchange(address _fromtoken, address _totoken, address _changer, uint256 _amount, uint256 _return) public;
}


contract bancortoken is owned, erc20token {
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
        erc20token(_name, _symbol) {
        if (bytes(_name).length == 0 || bytes(_symbol).length < 1 || bytes(_symbol).length > 6 || _formula == 0x0) 
            throw;

        numdecimalunits = _numdecimalunits;
        formula = _formula;
        events = _events;
        if (events == 0x0)
            return;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.newtoken();
    }

    
    modifier onlymanager {
        if (stage == stage.traded ||
            stage == stage.managed && msg.sender != owner ||
            stage == stage.crowdsale && msg.sender != crowdsale) 
            throw;
        _;
    }

    function setowner(address _newowner) public onlyowner {
        address prevowner = owner;
        super.setowner(_newowner);
        if (events == 0x0)
            return;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.newtokenowner(prevowner, owner);
    }

    
    function setformula(address _formula) public onlyowner returns (bool success) {
        bancorformula formulacontract = bancorformula(formula);
        if (formulacontract.newformula() != _formula)
            throw;

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

    
    function addreserve(address _token, uint8 _ratio) public onlyowner returns (bool success) {
        if (_token == address(this) || reserves[_token].isset || _ratio < 1 || _ratio > 100 || totalreserveratio + _ratio > 100) 
            throw;
        if (stage != stage.managed) 
            throw;

        reserves[_token].ratio = _ratio;
        reserves[_token].isenabled = true;
        reserves[_token].isset = true;
        reservetokens.push(_token);
        totalreserveratio += _ratio;
        dispatchupdate();
        return true;
    }

    
    function issue(address _to, uint256 _amount) public returns (bool success) {
        if (_amount == 0) 
            throw;
        if (stage == stage.managed && msg.sender != owner ||
            stage != stage.managed && msg.sender != crowdsale) 
            throw;
        if (totalsupply + _amount < totalsupply) 
            throw;
        if (balanceof[_to] + _amount < balanceof[_to]) 
            throw;
        if (stage != stage.managed && crowdsaleallowance >= 0 && _amount > uint256(crowdsaleallowance)) 
            throw;

        totalsupply += _amount;
        balanceof[_to] += _amount;
        if (stage != stage.managed && crowdsaleallowance >= 0)
            crowdsaleallowance = int256(_amount);

        dispatchupdate();
        dispatchtransfer(this, _to, _amount);
        return true;
    }

    
    function destroy(address _from, uint256 _amount) public onlymanager returns (bool success) {
        if (_amount == 0) 
            throw;
        if (_amount > totalsupply) 
            throw;
        if (_amount > balanceof[_from]) 
            throw;

        totalsupply = _amount;
        balanceof[_from] = _amount;
        dispatchupdate();
        dispatchtransfer(_from, this, _amount);
        return true;
    }

    
    function withdraw(address _reservetoken, address _to, uint256 _amount) public onlymanager returns (bool success) {
        if (!reserves[_reservetoken].isset || _amount == 0) 
            throw;

        reservetoken reservetoken = reservetoken(_reservetoken);
        return reservetoken.transfer(_to, _amount);
    }

    
    function disablereserve(address _reservetoken, bool _disable) public onlyowner {
        if (!reserves[_reservetoken].isset) 
            throw;

        reserves[_reservetoken].isenabled = !_disable;
        dispatchupdate();
    }

    
    function startcrowdsale(address _crowdsale, int256 _allowance) public onlyowner returns (bool success) {
        if (_crowdsale == 0x0 || _allowance == 0) 
            throw;
        if (stage != stage.managed || reservetokens.length == 0) 
            throw;

        crowdsale = _crowdsale;
        crowdsaleallowance = _allowance;
        stage = stage.crowdsale;
        dispatchupdate();
        return true;
    }

    
    function starttrading() public onlymanager returns (bool success) {
        if (totalsupply == 0) 
            throw;

        
        for (uint16 i = 0; i < reservetokens.length; ++i) {
            reservetoken reservetoken = reservetoken(reservetokens[i]);
            if (reservetoken.balanceof(this) == 0)
                throw;
        }

        stage = stage.traded;
        dispatchupdate();
        return true;
    }

    
    function getreturn(address _fromtoken, address _totoken, uint256 _amount) public constant returns (uint256 amount) {
        if (_fromtoken == _totoken) 
            throw;
        if (_fromtoken != address(this) && !reserves[_fromtoken].isset) 
            throw;
        if (_totoken != address(this) && !reserves[_totoken].isset) 
            throw;

        
        if (_totoken == address(this))
            return getpurchasereturn(_fromtoken, _amount);
        else if (_fromtoken == address(this))
            return getsalereturn(_totoken, _amount);

        
        uint256 tempamount = getpurchasereturn(_fromtoken, _amount);
        return getsalereturn(_totoken, tempamount);
    }

    
    function change(address _fromtoken, address _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256 amount) {
        if (_fromtoken == _totoken) 
            throw;
        if (_fromtoken != address(this) && !reserves[_fromtoken].isset) 
            throw;
        if (_totoken != address(this) && !reserves[_totoken].isset) 
            throw;

        
        if (_totoken == address(this))
            return buy(_fromtoken, _amount, _minreturn);
        else if (_fromtoken == address(this))
            return sell(_totoken, _amount, _minreturn);

        
        uint256 tempamount = buy(_fromtoken, _amount, 0);
        return sell(_totoken, tempamount, _minreturn);
    }

    
    function getpurchasereturn(address _reservetoken, uint256 _depositamount) public constant returns (uint256 amount) {
        reserve reserve = reserves[_reservetoken];
        if (!reserve.isset || !reserve.isenabled || _depositamount == 0) 
            throw;
        if (stage != stage.traded) 
            throw;

        reservetoken reservetoken = reservetoken(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);

        bancorformula formulacontract = bancorformula(formula);
        return formulacontract.calculatepurchasereturn(totalsupply, reservebalance, reserve.ratio, _depositamount);
    }

    
    function getsalereturn(address _reservetoken, uint256 _sellamount) public constant returns (uint256 amount) {
        reserve reserve = reserves[_reservetoken];
        if (!reserve.isset || _sellamount == 0) 
            throw;
        if (stage != stage.traded) 
            throw;

        reservetoken reservetoken = reservetoken(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);

        bancorformula formulacontract = bancorformula(formula);
        return formulacontract.calculatesalereturn(totalsupply, reservebalance, reserve.ratio, _sellamount);
    }

    
    function buy(address _reservetoken, uint256 _depositamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getpurchasereturn(_reservetoken, _depositamount);
        if (amount == 0 || amount < _minreturn) 
            throw;
        if (totalsupply + amount < totalsupply) 
            throw;

        reservetoken reservetoken = reservetoken(_reservetoken);
        if (!reservetoken.transferfrom(msg.sender, this, _depositamount)) 
            throw;

        totalsupply += amount;
        balanceof[msg.sender] += amount;
        dispatchchange(_reservetoken, this, msg.sender, _depositamount, amount);
        return amount;
    }

    
    function sell(address _reservetoken, uint256 _sellamount, uint256 _minreturn) public returns (uint256 amount) {
        if (balanceof[msg.sender] < _sellamount) 
            throw;

        amount = getsalereturn(_reservetoken, _sellamount);
        if (amount == 0 || amount < _minreturn) 
            throw;
        
        reservetoken reservetoken = reservetoken(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);
        if (reservebalance <= amount) 
            throw;

        totalsupply = _sellamount;
        balanceof[msg.sender] = _sellamount;
        if (!reservetoken.transfer(msg.sender, amount)) 
            throw;

        
        if (totalsupply == 0) {
            crowdsale = 0x0;
            crowdsaleallowance = 0;
            stage = stage.managed;
        }

        dispatchchange(this, _reservetoken, msg.sender, _sellamount, amount);
        return amount;
    }

    

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (stage == stage.crowdsale) 
            throw;

        super.transfer(_to, _value);

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
        }

        if (events == 0x0)
            return;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.tokentransfer(msg.sender, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        super.approve(_spender, _value);
        if (events == 0x0)
            return true;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.tokenapproval(msg.sender, _spender, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (stage == stage.crowdsale) 
            throw;

        super.transferfrom(_from, _to, _value);
        if (events == 0x0)
            return;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.tokentransfer(_from, _to, _value);
        return true;
    }

    

    function dispatchupdate() private {
        update();
        if (events == 0x0)
            return;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.tokenupdate();
    }

    function dispatchtransfer(address _from, address _to, uint256 _value) private {
        transfer(_from, _to, _value);
        if (events == 0x0)
            return;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.tokentransfer(_from, _to, _value);
    }

    function dispatchchange(address _fromtoken, address _totoken, address _changer, uint256 _amount, uint256 _return) private {
        change(_fromtoken, _totoken, _changer, _amount, _return);
        if (events == 0x0)
            return;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.tokenchange(_fromtoken, _totoken, _changer, _amount, _return);
    }

    
    function() {
        throw;
    }
}
