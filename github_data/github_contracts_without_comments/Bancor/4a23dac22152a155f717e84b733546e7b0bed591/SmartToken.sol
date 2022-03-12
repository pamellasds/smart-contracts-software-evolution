pragma solidity ^0.4.10;
import ;
import ;
import ;


contract smarttoken is erc20token, owned, smarttokeninterface {
    string public version = ;

    bool public transfersenabled = true;    
    address public changer = 0x0;           

    
    event newsmarttoken(address _token);
    
    event changerupdate(address _prevchanger, address _newchanger);

    
    function smarttoken(string _name, string _symbol, uint8 _decimals)
        erc20token(_name, _symbol, _decimals)
    {
        require(bytes(_symbol).length <= 6); 
        newsmarttoken(address(this));
    }

    
    modifier validamount(uint256 _amount) {
        require(_amount > 0);
        _;
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

    
    function disabletransfers(bool _disable) public controlleronly {
        transfersenabled = !_disable;
    }

    
    function issue(address _to, uint256 _amount)
        public
        controlleronly
        validaddress(_to)
        validamount(_amount)
    {
        require(_to != address(this)); 
        totalsupply = safeadd(totalsupply, _amount);
        balanceof[_to] = safeadd(balanceof[_to], _amount);
        transfer(this, _to, _amount);
    }

    
    function destroy(address _from, uint256 _amount)
        public
        controlleronly
        validamount(_amount)
    {
        balanceof[_from] = safesub(balanceof[_from], _amount);
        totalsupply = safesub(totalsupply, _amount);
        transfer(_from, this, _amount);
    }

    
    function setchanger(address _changer) public controlleronly {
        require(_changer != changer);
        address prevchanger = changer;
        changer = _changer;
        changerupdate(prevchanger, changer);
    }

    

    
    function transfer(address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transfer(_to, _value));

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
        }

        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transferfrom(_from, _to, _value));

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
        }

        return true;
    }

    
    function() {
        assert(false);
    }
}
