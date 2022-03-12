pragma solidity ^0.4.10;
import ;
import ;
import ;


contract smarttoken is erc20token, bancoreventsdispatcher, smarttokeninterface {
    string public version = ;
    uint8 public numdecimalunits = 0;       
    bool public transfersenabled = true;    
    address public changer = 0x0;           

    
    event changerupdate(address _prevchanger, address _newchanger);

    
    function smarttoken(string _name, string _symbol, uint8 _numdecimalunits, address _events)
        erc20token(_name, _symbol)
        bancoreventsdispatcher(_events)
    {
        require(bytes(_name).length != 0 && bytes(_symbol).length >= 1 && bytes(_symbol).length <= 6); 
        numdecimalunits = _numdecimalunits;

        if (address(events) != 0x0)
            events.newtoken();
    }

    
    modifier transfersallowed {
        assert(transfersenabled);
        _;
    }

    
    modifier controlleronly {
        assert((changer == 0x0 && msg.sender == owner) ||
               (changer != 0x0 && msg.sender == changer)); 
        _;
    }

    function setowner(address _newowner)
        public
        owneronly
        validaddress(_newowner)
    {
        address prevowner = owner;
        super.setowner(_newowner);

        if (address(events) != 0x0)
            events.tokenownerupdate(prevowner, owner);
    }

    
    function setnumdecimalunits(uint8 _numdecimalunits) public owneronly {
        numdecimalunits = _numdecimalunits;
    }

    
    function disabletransfers(bool _disable) public controlleronly {
        transfersenabled = !_disable;
    }

    
    function issue(address _to, uint256 _amount)
        public
        controlleronly
        validaddress(_to)
    {
        require(_to != address(this) && _amount != 0); 
        totalsupply = safeadd(totalsupply, _amount);
        balanceof[_to] = safeadd(balanceof[_to], _amount);
        dispatchtransfer(this, _to, _amount);
    }

    
    function destroy(address _from, uint256 _amount)
        public
        controlleronly
        validaddress(_from)
    {
        require(_from != address(this) && _amount != 0); 
        balanceof[_from] = safesub(balanceof[_from], _amount);
        totalsupply = safesub(totalsupply, _amount);
        dispatchtransfer(_from, this, _amount);
    }

    
    function setchanger(address _changer) public controlleronly {
        require(_changer != changer);
        address prevchanger = changer;
        changer = _changer;
        dispatchchangerupdate(prevchanger, changer);
    }

    

    
    function transfer(address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transfer(_to, _value));

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
        }

        if (address(events) != 0x0)
            events.tokentransfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transferfrom(_from, _to, _value));

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
        }

        if (address(events) != 0x0)
            events.tokentransfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        assert(super.approve(_spender, _value));

        if (address(events) != 0x0)
            events.tokenapproval(msg.sender, _spender, _value);
        return true;
    }

    

    function dispatchchangerupdate(address _prevchanger, address _newchanger) private {
        changerupdate(_prevchanger, _newchanger);

        if (address(events) != 0x0)
            events.tokenchangerupdate(_prevchanger, _newchanger);
    }

    function dispatchtransfer(address _from, address _to, uint256 _value) private {
        transfer(_from, _to, _value);

        if (address(events) != 0x0)
            events.tokentransfer(_from, _to, _value);
    }

    
    function() {
        assert(false);
    }
}
