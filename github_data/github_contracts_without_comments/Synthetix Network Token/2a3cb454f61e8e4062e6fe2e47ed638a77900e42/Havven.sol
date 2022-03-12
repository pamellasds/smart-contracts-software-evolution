

pragma solidity ^0.4.19;


import ;
import ;
import ;
import ;


contract havven is erc20token, owned {

    

    
    
    mapping(address => uint) public currentbalancesum;

    
    
    
    
    mapping(address => uint) public lastaveragebalance;

    
    
    
    
    
    mapping(address => uint) public penultimateaveragebalance;

    
    
    mapping(address => uint) public lasttransfertimestamp;

    
    uint public feeperiodstarttime = 3;
    
    
    
    
    
    uint lastfeeperiodstarttime = 2;
    
    uint penultimatefeeperiodstarttime = 1;

    
    uint public targetfeeperioddurationseconds = 4 weeks;
    
    uint constant minfeeperioddurationseconds = 1 days;
    
    uint constant maxfeeperioddurationseconds = 26 weeks;

    
    
    uint public lastfeescollected;

    mapping(address => bool) public haswithdrawnlastperiodfees;

    ethernomin public nomin;


    

    function havven(address _owner)
        erc20token(, ,
                   1e8 * unit, 
                   this)
        owned(_owner)
        public
    {
        lasttransfertimestamp[this] = now;
        feeperiodstarttime = now;
        lastfeeperiodstarttime = now  targetfeeperioddurationseconds;
        penultimatefeeperiodstarttime = now  2*targetfeeperioddurationseconds;
    }

    

    function setnomin(ethernomin _nomin) 
        public
        onlyowner
    {
        nomin = _nomin;
    }

    function settargetfeeperiodduration(uint duration)
        public
        precheckfeeperiodrollover
        onlyowner
    {
        require(minfeeperioddurationseconds <= duration &&
                duration <= maxfeeperioddurationseconds);
        targetfeeperioddurationseconds = duration;
        feeperioddurationupdated(duration);
    }


    

    
    function endow(address account, uint value)
        public
        onlyowner
        returns (bool)
    {
        
        
        return this.transfer(account, value);
    }

    
    function transfer(address _to, uint _value)
        public
        precheckfeeperiodrollover
        returns (bool)
    {
        uint senderprebalance = balanceof[msg.sender];
        uint recipientprebalance = balanceof[_to];

        
        
        super.transfer(_to, _value);

        
        
        adjustfeeentitlement(msg.sender, senderprebalance);
        adjustfeeentitlement(_to, recipientprebalance);

        return true;
    }

    
    function transferfrom(address _from, address _to, uint _value)
        public
        precheckfeeperiodrollover
        returns (bool)
    {
        uint senderprebalance = balanceof[_from];
        uint recipientprebalance = balanceof[_to];

        
        
        super.transferfrom(_from, _to, _value);

        
        
        adjustfeeentitlement(_from, senderprebalance);
        adjustfeeentitlement(_to, recipientprebalance);

        return true;
    }

    
    function withdrawfeeentitlement()
        public
        precheckfeeperiodrollover
    {
        
        require(!nomin.isfrozen(msg.sender));

        
        rolloverfee(msg.sender, lasttransfertimestamp[msg.sender], balanceof[msg.sender]);

        
        require(!haswithdrawnlastperiodfees[msg.sender]);

        uint feesowed = safedecdiv(safedecmul(lastaveragebalance[msg.sender],
                                              lastfeescollected),
                                   totalsupply);
        nomin.withdrawfee(msg.sender, feesowed);
        haswithdrawnlastperiodfees[msg.sender] = true;
        feeswithdrawn(msg.sender, feesowed);
    }

    
    function adjustfeeentitlement(address account, uint prebalance)
        internal
    {
        
        
        rolloverfee(account, lasttransfertimestamp[account], prebalance);

        currentbalancesum[account] = safeadd(
            currentbalancesum[account],
            safemul(prebalance, now  lasttransfertimestamp[account])
        );

        
        lasttransfertimestamp[account] = now;
    }

    
    function rolloverfee(address account, uint lasttransfertime, uint prebalance)
        internal
    {
        if (lasttransfertime < feeperiodstarttime) {
            if (lasttransfertime < lastfeeperiodstarttime) {
                
                if (lasttransfertime < penultimatefeeperiodstarttime) {
                    
                    
                    penultimateaveragebalance[account] = prebalance;
                
                } else {
                    
                    penultimateaveragebalance[account] = safediv(
                        safeadd(currentbalancesum[account], safemul(prebalance, (lastfeeperiodstarttime  lasttransfertime))),
                        (lastfeeperiodstarttime  penultimatefeeperiodstarttime)
                    );
                }

                
                
                lastaveragebalance[account] = prebalance;

            
            } else {
                
                penultimateaveragebalance[account] = lastaveragebalance[account];

                
                lastaveragebalance[account] = safediv(
                    safeadd(currentbalancesum[account], safemul(prebalance, (feeperiodstarttime  lasttransfertime))),
                    (feeperiodstarttime  lastfeeperiodstarttime)
                );
            }

            
            currentbalancesum[account] = 0;
            haswithdrawnlastperiodfees[account] = false;
            lasttransfertimestamp[account] = feeperiodstarttime;
        }
    }

    
    function recomputelastaveragebalance()
        public
        precheckfeeperiodrollover
        returns (uint)
    {
        adjustfeeentitlement(msg.sender, balanceof[msg.sender]);
        return lastaveragebalance[msg.sender];
    }

    function rolloverfeeperiod()
        public
    {
        checkfeeperiodrollover();
    }

    

    
    modifier postcheckfeeperiodrollover
    {
        _;
        checkfeeperiodrollover();
    }

    modifier precheckfeeperiodrollover
    {
        checkfeeperiodrollover();
        _;
    }

    function checkfeeperiodrollover()
        internal
    {
        
        if (feeperiodstarttime + targetfeeperioddurationseconds <= now) {
            lastfeescollected = nomin.feepool();

            
            penultimatefeeperiodstarttime = lastfeeperiodstarttime;
            lastfeeperiodstarttime = feeperiodstarttime;
            feeperiodstarttime = now;
            
            feeperiodrollover(now);
        }
    }

    

    event feeperiodrollover(uint timestamp);

    event feeperioddurationupdated(uint duration);

    event feeswithdrawn(address indexed account, uint fees);

}
