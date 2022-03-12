

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;


contract supplyschedule is owned, math {
    using safemath for uint;
    using safedecimalmath for uint;

    
    uint public lastmintevent;

    
    uint public weekcounter;

    
    uint public minterreward = 200 * safedecimalmath.unit();

    
    
    uint public constant initial_weekly_supply = 1442307692307692307692307;    

    
    address public synthetixproxy;

    
    uint public constant max_minter_reward = 200 * safedecimalmath.unit();

    
    uint public constant mint_period_duration = 1 weeks;

    uint public constant inflation_start_date = 1551830400; 
    uint8 public constant supply_decay_start = 40; 
    uint8 public constant supply_decay_end = 234; 
    
    
    uint public constant decay_rate = 12500000000000000; 

    
    uint public constant terminal_supply_rate_annual = 25000000000000000; 
    
    constructor(
        address _owner,
        uint _lastmintevent,
        uint _currentweek)
        owned(_owner)
        public
    {
        lastmintevent = _lastmintevent;
        weekcounter = _currentweek;
    }

    
    
    
    function mintablesupply()
        external
        view
        returns (uint)
    {
        uint totalamount;

        if (!ismintable()) {
            return totalamount;
        }
        
        uint remainingweekstomint = weekssincelastissuance();
          
        uint currentweek = weekcounter;
        
        
        
        while (remainingweekstomint > 0) {
            currentweek++;            
            
            
            if (currentweek < supply_decay_start) {
                totalamount = totalamount.add(initial_weekly_supply);
                remainingweekstomint;
            }
            
            else if (currentweek <= supply_decay_end) {
                
                
                uint decaycount = currentweek.sub(supply_decay_start 1);
                
                totalamount = totalamount.add(tokendecaysupplyforweek(decaycount));
                remainingweekstomint;
            } 
            
            
            else {
                uint totalsupply = isynthetix(synthetixproxy).totalsupply();
                uint currenttotalsupply = totalsupply.add(totalamount);

                totalamount = totalamount.add(terminalinflationsupply(currenttotalsupply, remainingweekstomint));
                remainingweekstomint = 0;
            }
        }
        
        return totalamount;
    }

    
    function tokendecaysupplyforweek(uint counter)
        public 
        view
        returns (uint)
    {   
        
        
        uint effectivedecay = powdecimal(safedecimalmath.unit().sub(decay_rate), counter);
        uint supplyforweek = initial_weekly_supply.multiplydecimal(effectivedecay);

        return supplyforweek;
    }    
    
    
    function terminalinflationsupply(uint totalsupply, uint numofweeks)
        public
        pure
        returns (uint)
    {   
        
        uint effectivecompoundrate = powdecimal(safedecimalmath.unit().add(terminal_supply_rate_annual.div(52)), numofweeks);

        
        return totalsupply.multiplydecimal(effectivecompoundrate.sub(safedecimalmath.unit()));
    }

    
    function weekssincelastissuance()
        public
        view
        returns (uint)
    {
        
        
        uint timediff = lastmintevent > 0 ? now.sub(lastmintevent) : now.sub(inflation_start_date);
        return timediff.div(mint_period_duration);
    }

    
    function ismintable()
        public
        view
        returns (bool)
    {
        if (now  lastmintevent > mint_period_duration)
        {
            return true;
        }
        return false;
    }

    

    
    function recordmintevent(uint supplyminted)
        external
        onlysynthetix
        returns (bool)
    {
        uint numberofweeksissued = weekssincelastissuance();

        
        weekcounter = weekcounter.add(numberofweeksissued);

        
        lastmintevent = now;

        emit supplyminted(supplyminted, numberofweeksissued, now);
        return true;
    }

    
    function setminterreward(uint amount)
        external
        onlyowner
    {
        require(amount <= max_minter_reward, );
        minterreward = amount;
        emit minterrewardupdated(minterreward);
    }

    

    
    function setsynthetixproxy(isynthetix _synthetixproxy)
        external
        onlyowner
    {
        synthetixproxy = _synthetixproxy;
    }

    

    
    modifier onlysynthetix() {
        require(msg.sender == address(proxy(synthetixproxy).target()), );
        _;
    }

    
    
    event supplyminted(uint supplyminted, uint numberofweeksissued, uint timestamp);

    
    event minterrewardupdated(uint newrewardamount);
}
