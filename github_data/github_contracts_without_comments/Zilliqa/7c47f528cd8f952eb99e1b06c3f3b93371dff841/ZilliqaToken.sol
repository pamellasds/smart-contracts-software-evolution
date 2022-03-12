pragma solidity ^0.4.18;

import ;

contract zilliqatoken is pausabletoken {
    string  public  constant name = ;
    string  public  constant symbol = ;
    uint8   public  constant decimals = 12;

    modifier validdestination( address to )
    {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function zilliqatoken( address _admin, uint _totaltokenamount ) 
    {
        
        admin = _admin;

        
        totalsupply = _totaltokenamount;
        balances[msg.sender] = _totaltokenamount;
        transfer(address(0x0), msg.sender, _totaltokenamount);
    }

    function transfer(address _to, uint _value) validdestination(_to) returns (bool) 
    {
        return super.transfer(_to, _value);
    }

    function transferfrom(address _from, address _to, uint _value) validdestination(_to) returns (bool) 
    {
        return super.transferfrom(_from, _to, _value);
    }

    event burn(address indexed _burner, uint _value);

    function burn(uint _value) returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalsupply = totalsupply.sub(_value);
        burn(msg.sender, _value);
        transfer(msg.sender, address(0x0), _value);
        return true;
    }

    
    function burnfrom(address _from, uint256 _value) returns (bool) 
    {
        assert( transferfrom( _from, msg.sender, _value ) );
        return burn(_value);
    }

    function emergencyerc20drain( erc20 token, uint amount ) onlyowner {
        
        token.transfer( owner, amount );
    }

    event admintransferred(address indexed previousadmin, address indexed newadmin);

    function changeadmin(address newadmin) onlyowner {
        
        admintransferred(admin, newadmin);
        admin = newadmin;
    }
}
