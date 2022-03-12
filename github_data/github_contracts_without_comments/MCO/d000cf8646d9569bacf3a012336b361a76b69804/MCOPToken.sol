pragma solidity ^0.4.18;

import ;





contract mcoptoken is pausabletoken {
    using safemath for uint;

    
    string public constant name = ;
    string public constant symbol = ;
    uint public constant decimals = 18;


    
    
    address public minter; 

    
    modifier onlyminter {
        assert(msg.sender == minter);
        _;
    }

    modifier islaterthan (uint x){
        assert(now > x);
        _;
    }
    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    
    function mcoptoken(address _minter, address _admin) 
        public 
        validaddress(_minter)
        validaddress(_admin)
    {
        minter = _minter;
        transferownership(_admin);
    }

    

    function mint(address receipent, uint amount)
        external
        onlyminter
        returns (bool)
    {
        balances[receipent] = balances[receipent].add(amount);
        totalsupply = totalsupply.add(amount);
        return true;
    }
}