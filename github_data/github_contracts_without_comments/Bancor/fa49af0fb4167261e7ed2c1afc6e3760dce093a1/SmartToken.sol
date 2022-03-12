pragma solidity ^0.4.11;
import ;
import ;
import ;


contract smarttoken is ismarttoken, erc20token, tokenholder {
    string public version = ;

    bool public transfersenabled = true;    

    
    event newsmarttoken(address _token);
    
    event issuance(uint256 _amount);
    
    event destruction(uint256 _amount);

    
    function smarttoken(string _name, string _symbol, uint8 _decimals)
        erc20token(_name, _symbol, _decimals)
    {
        require(bytes(_symbol).length <= 6); 
        newsmarttoken(address(this));
    }

    
    modifier transfersallowed {
        assert(transfersenabled);
        _;
    }

    
    function disabletransfers(bool _disable) public owneronly {
        transfersenabled = !_disable;
    }

    
    function issue(address _to, uint256 _amount)
        public
        owneronly
        validaddress(_to)
        notthis(_to)
        validamount(_amount)
    {
        totalsupply = safeadd(totalsupply, _amount);
        balanceof[_to] = safeadd(balanceof[_to], _amount);

        issuance(_amount);
        transfer(this, _to, _amount);
    }

    
    function destroy(address _from, uint256 _amount)
        public
        owneronly
        validamount(_amount)
    {
        balanceof[_from] = safesub(balanceof[_from], _amount);
        totalsupply = safesub(totalsupply, _amount);

        transfer(_from, this, _amount);
        destruction(_amount);
    }

    

    
    function transfer(address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transfer(_to, _value));

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
            destruction(_value);
        }

        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transferfrom(_from, _to, _value));

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
            destruction(_value);
        }

        return true;
    }

    
    function() {
        assert(false);
    }
}
