

pragma solidity ^0.4.20;


import ;
import ;
import ;
import ;
import ;


contract havven is externstateproxytoken, selfdestructible {

    

    
    
    mapping(address => uint) public currentbalancesum;

    
    
    
    
    
    
    mapping(address => uint) public lastaveragebalance;

    
    
    
    
    
    
    
    mapping(address => uint) public penultimateaveragebalance;

    
    
    mapping(address => uint) public lasttransfertimestamp;

    
    uint public feeperiodstarttime = 3;
    
    
    
    
    
    uint public lastfeeperiodstarttime = 2;
    
    uint public penultimatefeeperiodstarttime = 1;

    
    uint public targetfeeperioddurationseconds = 4 weeks;
    
    uint constant min_fee_period_duration_seconds = 1 days;
    
    uint constant max_fee_period_duration_seconds = 26 weeks;

    
    
    uint public lastfeescollected;

    mapping(address => bool) public haswithdrawnlastperiodfees;

    ethernomin public nomin;
    havvenescrow public escrow;


    

    function havven(tokenstate initialstate, address _owner)
        externstateproxytoken(, , 1e8 * unit, address(this), initialstate, _owner)
        selfdestructible(_owner, _owner)
        
        public
    {
        lasttransfertimestamp[this] = now;
        feeperiodstarttime = now;
        lastfeeperiodstarttime = now  targetfeeperioddurationseconds;
        penultimatefeeperiodstarttime = now  2*targetfeeperioddurationseconds;
    }


    

    function setnomin(ethernomin _nomin) 
        external
        optionalproxy_onlyowner
    {
        nomin = _nomin;
    }

    function setescrow(havvenescrow _escrow)
        external
        optionalproxy_onlyowner
    {
        escrow = _escrow;
    }

    function settargetfeeperiodduration(uint duration)
        external
        postcheckfeeperiodrollover
        optionalproxy_onlyowner
    {
        require(min_fee_period_duration_seconds <= duration &&
                duration <= max_fee_period_duration_seconds);
        targetfeeperioddurationseconds = duration;
        feeperioddurationupdated(duration);
    }


    

    
    function endow(address account, uint value)
        external
        optionalproxy_onlyowner
        returns (bool)
    {

        
        
        return _transfer(this, account, value);
    }

    
    function transfer(address to, uint value)
        external
        optionalproxy
        returns (bool)
    {
        return _transfer(messagesender, to, value);
    }

    
    function _transfer(address sender, address to, uint value)
        internal
        precheckfeeperiodrollover
        returns (bool)
    {

        uint senderprebalance = state.balanceof(sender);
        uint recipientprebalance = state.balanceof(to);

        
        
        _transfer_byproxy(sender, to, value);

        
        
        adjustfeeentitlement(sender, senderprebalance);
        adjustfeeentitlement(to, recipientprebalance);

        return true;
    }

    
    function transferfrom(address from, address to, uint value)
        external
        precheckfeeperiodrollover
        optionalproxy
        returns (bool)
    {
        uint senderprebalance = state.balanceof(from);
        uint recipientprebalance = state.balanceof(to);

        
        
        _transferfrom_byproxy(messagesender, from, to, value);

        
        
        adjustfeeentitlement(from, senderprebalance);
        adjustfeeentitlement(to, recipientprebalance);

        return true;
    }

    
    function withdrawfeeentitlement()
        public
        precheckfeeperiodrollover
        optionalproxy
    {
        address sender = messagesender;

        
        require(!nomin.frozen(sender));

        
        rolloverfee(sender, lasttransfertimestamp[sender], state.balanceof(sender));

        
        require(!haswithdrawnlastperiodfees[sender]);

        uint feesowed;

        if (escrow != havvenescrow(0)) {
            feesowed = escrow.totalvestedaccountbalance(sender);
        }

        feesowed = safediv_dec(safemul_dec(safeadd(feesowed, lastaveragebalance[sender]),
                                           lastfeescollected),
                               totalsupply);

        haswithdrawnlastperiodfees[sender] = true;
        if (feesowed != 0) {
            nomin.withdrawfee(sender, feesowed);
            feeswithdrawn(sender, sender, feesowed);
        }
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

    
    function _recomputeaccountlastaveragebalance(address account)
        internal
        precheckfeeperiodrollover
        returns (uint)
    {
        adjustfeeentitlement(account, state.balanceof(account));
        return lastaveragebalance[account];
    }

    
    function recomputelastaveragebalance()
        external
        optionalproxy
        returns (uint)
    {
        return _recomputeaccountlastaveragebalance(messagesender);
    }

    
    function recomputeaccountlastaveragebalance(address account)
        external
        returns (uint)
    {
        return _recomputeaccountlastaveragebalance(account);
    }

    function rolloverfeeperiod()
        public
    {
        checkfeeperiodrollover();
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


    

    event feeperiodrollover(uint timestamp);

    event feeperioddurationupdated(uint duration);

    event feeswithdrawn(address account, address indexed accountindex, uint fees);
}
