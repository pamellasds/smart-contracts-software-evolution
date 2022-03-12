pragma solidity ^0.4.4;

import ;

contract gntallocation {
    
    
    
    
    uint256 constant totalallocations = 30000;

    
    mapping (address => uint256) allocations;

    golemnetworktoken gnt;
    uint256 unlockedat;

    uint256 tokenscreated = 0;

    function gntallocation(address _golemfactory) internal {
        gnt = golemnetworktoken(msg.sender);
        unlockedat = now + 6 * 30 days;

        
        allocations[_golemfactory] = 20000; 

        
        allocations[0xde00] = 2500; 
        allocations[0xde01] =  730; 
        allocations[0xde02] =  730;
        allocations[0xde03] =  730;
        allocations[0xde04] =  730;
        allocations[0xde05] =  730;
        allocations[0xde06] =  630; 
        allocations[0xde07] =  630;
        allocations[0xde08] =  630;
        allocations[0xde09] =  630;
        allocations[0xde10] =  310; 
        allocations[0xde11] =  153; 
        allocations[0xde12] =  150; 
        allocations[0xde13] =  100; 
        allocations[0xde14] =  100;
        allocations[0xde15] =  100;
        allocations[0xde16] =   70; 
        allocations[0xde17] =   70;
        allocations[0xde18] =   70;
        allocations[0xde19] =   70;
        allocations[0xde20] =   70;
        allocations[0xde21] =   42; 
        allocations[0xde22] =   25; 
    }

    
    
    function unlock() external {
        if (now < unlockedat) throw;

        
        if (tokenscreated == 0)
            tokenscreated = gnt.balanceof(this);

        var allocation = allocations[msg.sender];
        allocations[msg.sender] = 0;
        var totransfer = tokenscreated * allocation / totalallocations;

        
        if (!gnt.transfer(msg.sender, totransfer)) throw;
    }
}
