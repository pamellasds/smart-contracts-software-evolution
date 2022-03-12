pragma solidity ^0.4.4;

import ;





contract seeletoken is pausabletoken {
    using safemath for uint;

    
    string public constant name = ;
    string public constant symbol = ;
    uint public constant decimals = 18;

    
    uint public currentsupply;

    
    
    address public minter; 

    
    uint public starttime;
    
    uint public endtime;

    
    modifier onlyminter {
        assert(msg.sender == minter);
        _;
    }

    modifier islaterthan (uint x){
        assert(now > x);
        _;
    }

    modifier maxtokenamountnotreached (uint amount){
        assert(currentsupply.add(amount) <= totalsupply);
        _;
    }

    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    
    function seeletoken(address _minter, address _admin, uint _maxtotalsupply, uint _starttime, uint _endtime) 
        public 
        validaddress(_admin)
        validaddress(_minter)
        {
        minter = _minter;
        starttime = _starttime;
        endtime = _endtime;
        totalsupply = _maxtotalsupply;
        transferownership(_admin);
    }

    

    function mint(address receipent, uint amount)
        external
        onlyminter
        maxtokenamountnotreached(amount)
        returns (bool)
    {
        require(now <= endtime);
        balances[receipent] = balances[receipent].add(amount);
        currentsupply = currentsupply.add(amount);
        return true;
    }
}