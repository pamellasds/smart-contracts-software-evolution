pragma solidity ^0.4.10;
import ;
import ;
import ;
import ;


contract smarttoken is owned, standardtoken {
    uint8 public numdecimalunits = 0;   
    address public events = 0x0;        
    address public changer = 0x0;       
    bool public transfersenabled = true;

    
    event changerupdate(address _prevchanger, address _newchanger);
    event supplyupdate(uint256 _totalsupply);

    
    function smarttoken(string _name, string _symbol, uint8 _numdecimalunits, address _events)
        standardtoken(_name, _symbol)
    {
        require(bytes(_name).length != 0 && bytes(_symbol).length >= 1 && bytes(_symbol).length <= 6); 

        numdecimalunits = _numdecimalunits;
        events = _events;
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.newtoken();
    }

    
    modifier transfersallowed {
        assert(transfersenabled);
        _;
    }

    
    modifier manageronly {
        assert((changer == 0x0 && msg.sender == owner) ||
               (changer != 0x0 && msg.sender == changer)); 
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

    
    function setnumdecimalunits(uint8 _numdecimalunits) public owneronly {
        numdecimalunits = _numdecimalunits;
    }

    
    function disabletransfers(bool _disable) public manageronly {
        transfersenabled = !_disable;
    }

    
    function issue(address _to, uint256 _amount) public manageronly returns (bool success) {
         
        require(_amount != 0);
         
        assert(totalsupply + _amount >= totalsupply);
        
        assert(balanceof[_to] + _amount >= balanceof[_to]);

        totalsupply += _amount;
        balanceof[_to] += _amount;
        dispatchsupplyupdate(totalsupply);
        dispatchtransfer(this, _to, _amount);
        return true;
    }

    
    function destroy(address _from, uint256 _amount) public manageronly returns (bool success) {
        require(_amount != 0 && _amount <= balanceof[_from]); 

        totalsupply = _amount;
        balanceof[_from] = _amount;
        dispatchtransfer(_from, this, _amount);
        dispatchsupplyupdate(totalsupply);
        return true;
    }

    
    function setchanger(address _changer, bool _disabletransfers) public manageronly returns (bool success) {
        address prevchanger = changer;
        changer = _changer;
        transfersenabled = !_disabletransfers;
        dispatchchangerupdate(prevchanger, changer);
        return true;
    }

    

    
    function transfer(address _to, uint256 _value) public transfersallowed returns (bool success) {
        super.transfer(_to, _value);

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
            dispatchsupplyupdate(totalsupply);
        }

        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokentransfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public transfersallowed returns (bool success) {
        super.transferfrom(_from, _to, _value);

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
            dispatchsupplyupdate(totalsupply);
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

    

    function dispatchchangerupdate(address _prevchanger, address _newchanger) private {
        changerupdate(_prevchanger, _newchanger);
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokenchangerupdate(_prevchanger, _newchanger);
    }

    function dispatchsupplyupdate(uint256 _totalsupply) private {
        supplyupdate(_totalsupply);
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokensupplyupdate(_totalsupply);
    }

    function dispatchtransfer(address _from, address _to, uint256 _value) private {
        transfer(_from, _to, _value);
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokentransfer(_from, _to, _value);
    }

    
    function() {
        assert(false);
    }
}
