pragma solidity ^0.4.9;
import ;





contract reservetoken { 
    function balanceof(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract bancorformula {
    function calculatepurchasevalue(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _depositamount) public constant returns (uint256 value);
    function calculatesalevalue(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256 value);
    function newformula() public constant returns (address newformula);
}

contract bancorevents {
    function newtoken() public;
    function tokenupdate() public;
    function tokentransfer(address _from, address _to, uint256 _value) public;
    function tokenapproval(address _owner, address _spender, uint256 _value) public;
    function tokenconversion(address _reservetoken, address _trader, bool _ispurchase, uint256 _totalsupply,
                             uint256 _reservebalance, uint256 _tokenamount, uint256 _reserveamount) public;
}


contract bancortoken is owned {
    enum stage { managed, crowdsale, traded }

    string public standard = ;
    string public name = ;
    string public symbol = ;                          
    uint8 public numdecimalunits = 0;                   
    uint256 public totalsupply = 0;
    address public formula = 0x0;                       
    address public events = 0x0;                        
    address public crowdsale = 0x0;                     
    uint256 public crowdsaleallowance = 0;              
    stage public stage = stage.managed;                 
    address[] public reservetokens;                     
    mapping (address => uint8) public reserveratioof;   
    mapping (address => uint256) public balanceof;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event update();
    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);
    event conversion(address indexed _reservetoken, address indexed _trader, bool _ispurchase,
                     uint256 _totalsupply, uint256 _reservebalance, uint256 _tokenamount, uint256 _reserveamount);

    
    function bancortoken(string _name, string _symbol, uint8 _numdecimalunits, address _formula, address _events) {
        if (bytes(_name).length == 0 || bytes(_symbol).length < 1 || bytes(_symbol).length > 6 || _formula == 0x0) 
            throw;

        name = _name;
        symbol = _symbol;
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

    
    function setformula(address _formula) public onlyowner returns (bool success) {
        bancorformula formulacontract = bancorformula(formula);
        if (formulacontract.newformula() != _formula)
            throw;

        formula = _formula;
        return true;
    }

    
    function reservetokencount() public returns (uint8 count) {
        return uint8(reservetokens.length);
    }

    
    function addreserve(address _token, uint8 _ratio) public onlyowner returns (bool success) {
        if (reserveratioof[_token] != 0 || _ratio < 1 || _ratio > 99) 
            throw;
        if (stage != stage.managed) 
            throw;

        reserveratioof[_token] = _ratio;
        reservetokens.push(_token);
        dispatchupdate();
        return true;
    }

    
    function issue(address _to, uint256 _amount) public onlymanager returns (bool success) {
        if (totalsupply + _amount < totalsupply) 
            throw;
        if (balanceof[_to] + _amount < balanceof[_to]) 
            throw;
        if (stage == stage.crowdsale && _amount > crowdsaleallowance) 
            throw;

        totalsupply += _amount;
        balanceof[_to] += _amount;
        if (stage == stage.crowdsale)
            crowdsaleallowance = _amount;

        dispatchupdate();
        dispatchtransfer(this, _to, _amount);
        return true;
    }

    
    function destroy(address _from, uint256 _amount) public onlymanager returns (bool success) {
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
        if (reserveratioof[_reservetoken] == 0 || _amount == 0) 
            throw;

        reservetoken reservetoken = reservetoken(_reservetoken);
        return reservetoken.transfer(_to, _amount);
    }

    
    function startcrowdsale(address _crowdsale, uint256 _allowance) public onlyowner returns (bool success) {
        if (stage != stage.managed || crowdsale == 0x0 || reservetokens.length == 0) 
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

    
    function buy(address _reservetoken, uint256 _depositamount, uint256 _minimumvalue) public returns (uint256 value) {
        uint8 reserveratio = reserveratioof[_reservetoken];
        if (reserveratio == 0 || _depositamount == 0) 
            throw;
        if (stage != stage.traded) 
            throw;

        reservetoken reservetoken = reservetoken(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);

        bancorformula formulacontract = bancorformula(formula);
        value = formulacontract.calculatepurchasevalue(totalsupply, reservebalance, reserveratio, _depositamount);
        if (value == 0 || value < _minimumvalue) 
            throw;
        if (totalsupply + value < totalsupply) 
            throw;
        if (!reservetoken.transferfrom(msg.sender, this, _depositamount)) 
            throw;

        uint256 startsupply = totalsupply;
        totalsupply += value;
        balanceof[msg.sender] += value;
        dispatchconversion(_reservetoken, msg.sender, true, startsupply, reservebalance, value, _depositamount);
        return value;
    }

    
    function sell(address _reservetoken, uint256 _sellamount, uint256 _minimumvalue) public returns (uint256 value) {
        uint8 reserveratio = reserveratioof[_reservetoken];
        if (reserveratio == 0 || _sellamount == 0) 
            throw;
        if (stage != stage.traded) 
            throw;
        if (balanceof[msg.sender] < _sellamount) 
            throw;

        reservetoken reservetoken = reservetoken(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);

        bancorformula formulacontract = bancorformula(formula);
        value = formulacontract.calculatesalevalue(totalsupply, reservebalance, reserveratio, _sellamount);
        if (value == 0 || value < _minimumvalue) 
            throw;
        if (reservebalance <= value) 
            throw;

        uint256 startsupply = totalsupply;
        totalsupply = _sellamount;
        balanceof[msg.sender] = _sellamount;
        if (!reservetoken.transfer(msg.sender, value)) 
            throw;

        
        if (totalsupply == 0) {
            crowdsale = 0x0;
            crowdsaleallowance = 0;
            stage = stage.managed;
        }

        dispatchconversion(_reservetoken, msg.sender, false, startsupply, reservebalance, _sellamount, value);
        return value;
    }

    

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balanceof[msg.sender] < _value) 
            throw;
        if (balanceof[_to] + _value < balanceof[_to]) 
            throw;

        balanceof[msg.sender] = _value;
        if (_to == address(this)) 
            totalsupply = _value;
        else
            balanceof[_to] += _value;

        dispatchtransfer(msg.sender, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        if (_value != 0 && allowance[msg.sender][_spender] != 0)
            throw;

        allowance[msg.sender][_spender] = _value;

        approval(msg.sender, _spender, _value);
        if (events == 0x0)
            return true;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.tokenapproval(msg.sender, _spender, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balanceof[_from] < _value) 
            throw;
        if (balanceof[_to] + _value < balanceof[_to]) 
            throw;
        if (_value > allowance[_from][msg.sender]) 
            throw;

        balanceof[_from] = _value;
        balanceof[_to] += _value;
        allowance[_from][msg.sender] = _value;

        dispatchtransfer(_from, _to, _value);
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

    function dispatchconversion(address _reservetoken, address _trader, bool _ispurchase,
                                uint256 _totalsupply, uint256 _reservebalance, uint256 _tokenamount, uint256 _reserveamount) private {
        conversion(_reservetoken, _trader, _ispurchase, _totalsupply, _reservebalance, _tokenamount, _reserveamount);
        if (events == 0x0)
            return;

        bancorevents eventscontract = bancorevents(events);
        eventscontract.tokenconversion(_reservetoken, _trader, _ispurchase, _totalsupply, _reservebalance, _tokenamount, _reserveamount);
    }

    

    function() {
        throw;
    }
}
