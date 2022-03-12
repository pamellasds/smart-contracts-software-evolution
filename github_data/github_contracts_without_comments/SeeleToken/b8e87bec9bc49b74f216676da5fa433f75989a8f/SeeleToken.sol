pragma solidity ^0.4.18;

import ;





contract seeletoken is pausabletoken {
    using safemath for uint;

    
    string public constant name = ;
    string public constant symbol = ;
    uint public constant decimals = 18;

    
    uint public currentsupply;

    
    
    address public minter; 

    
    mapping (address => uint) public lockedbalances;

    
    bool public claimedflag;  

    
    modifier onlyminter {
        assert(msg.sender == minter);
        _;
    }

    modifier canclaimed {
        assert(claimedflag == true);
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

    
    function seeletoken(address _minter, address _admin, uint _maxtotalsupply) 
        public 
        validaddress(_admin)
        validaddress(_minter)
        {
        minter = _minter;
        totalsupply = _maxtotalsupply;
        claimedflag = false;
        transferownership(_admin);
    }

    

    function mint(address receipent, uint amount, bool islock)
        external
        onlyminter
        maxtokenamountnotreached(amount)
        returns (bool)
    {
        if (islock ) {
            lockedbalances[receipent] = lockedbalances[receipent].add(amount);
        } else {
            balances[receipent] = balances[receipent].add(amount);
        }
        currentsupply = currentsupply.add(amount);
        return true;
    }


    function setclaimedflag(bool flag) 
        public
        onlyowner 
    {
        claimedflag = flag;
    }

     

    
    function claimtokens(address[] receipents)
        public
        canclaimed
    {        
        for (uint i = 0; i < receipents.length; i++) {
            address receipent = receipents[i];
            balances[receipent] = balances[receipent].add(lockedbalances[receipent]);
            lockedbalances[receipent] = 0;
        }
    }

    
    function lockedbalanceof(address _addr) 
        constant 
        public
        returns (uint balance) 
        {
        return lockedbalances[_addr];
    }
}