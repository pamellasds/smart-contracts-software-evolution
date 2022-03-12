

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;


contract supplyschedule is owned, math {
    using safemath for uint;
    using safedecimalmath for uint;

    
    uint public mintperiodduration = 1 weeks;

    
    uint public lastmintevent;

    
    uint public weekcounter;

    
    uint public minterreward = 50 * safedecimalmath.unit();

    
    uint public initialweeklysupply;    

    
    address public synthetixproxy;

    uint public constant inflation_start_date = 1551830400; 
    uint8 public constant supply_decay_start = 40; 
    uint8 public constant supply_decay_end = 234; 
    
    
    uint public constant decay_rate = 125 * safedecimalmath.unit() / 1e4; 

    
    uint public constant terminal_supply_rate_annual = 25 * safedecimalmath.unit() / 1e3; 
    
    constructor(
        address _owner,
        uint _lastmintevent,
        uint _currentweek)
        owned(_owner)
        public
    {
        
        initialweeklysupply = 75e6 * safedecimalmath.unit() / 52;

        lastmintevent = _lastmintevent;
        weekcounter = _currentweek;
    }

    
    
    
    function mintablesupply()
        public
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
                totalamount = totalamount.add(initialweeklysupply);
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
        uint supplyforweek = initialweeklysupply.multiplydecimal(effectivedecay);

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
        return timediff.div(mintperiodduration);
    }

    
    function ismintable()
        public
        view
        returns (bool)
    {
        if (now  lastmintevent > mintperiodduration)
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

    event logint(string name, uint value);
}
