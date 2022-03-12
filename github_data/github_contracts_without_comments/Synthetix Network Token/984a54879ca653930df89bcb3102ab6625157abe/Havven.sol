

pragma solidity ^0.4.19;


import ;
import ;
import ;
import ;


contract havven is erc20token, owned {

    

    
    
    mapping(address => uint) currentbalancesum;

    
    
    
    
    mapping(address => uint) public lastaveragebalance;

    
    
    
    
    
    mapping(address => uint) public penultimateaveragebalance;

    
    
    mapping(address => uint) lasttransfertimestamp;

    mapping(address => bool) haswithdrawnlastperiodfees;

    
    uint public feeperiodstarttime;
    
    uint public targetfeeperioddurationseconds = 1 weeks;
    
    uint constant minfeeperioddurationseconds = 1 days;
    
    uint lastfeeperiodduration = 1;

    
    
    uint public lastfeescollected;

    
    
    
    mapping(address => court.vote) public vote;
    
    mapping(address => address) public votetarget;

    ethernomin nomin;
    court public court;


    

    function havven(address _oracle, address _beneficiary,
                    uint _initialetherprice, address _owner)
        erc20token(, ,
                   1e8 * unit, 
                   this)
        owned(_owner)
        public
    {
        feeperiodstarttime = now;
        nomin = new ethernomin(this, _oracle,
                               _beneficiary,
                               _initialetherprice,
                               _owner);
        court = new court(this, nomin, _owner);
    }


    

    function settargetfeeperiodduration(uint duration)
        public
        postcheckfeeperiodrollover
        onlyowner
    {
        require(duration >= minfeeperioddurationseconds);
        targetfeeperioddurationseconds = duration;
        feeperioddurationupdated(duration);
    }


    

    function hasvoted(address account)
        public
        view
        returns (bool)
    {
        return vote[account] != court.vote.abstention;
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
        postcheckfeeperiodrollover
        returns (bool)
    {
        uint senderprebalance = balanceof[msg.sender];
        uint recipientprebalance = balanceof[_to];

        
        
        super.transfer(_to, _value);

        
        if (_value == 0) {
            return true;
        }

        adjustfeeentitlement(msg.sender, senderprebalance);
        adjustfeeentitlement(_to, recipientprebalance);

        return true;
    }

    
    function transferfrom(address _from, address _to, uint _value)
        public
        postcheckfeeperiodrollover
        returns (bool)
    {
        uint senderprebalance = balanceof[_from];
        uint recipientprebalance = balanceof[_to];

        
        
        super.transferfrom(_from, _to, _value);

        
        if (_value == 0) {
            return true;
        }

        adjustfeeentitlement(_from, senderprebalance);
        adjustfeeentitlement(_to, recipientprebalance);

        return true;
    }

    
    function adjustfeeentitlement(address account, uint prebalance)
        internal
    {
        uint lasttransfertime = lasttransfertimestamp[account];

        
        
        rolloverfee(account, lasttransfertime, prebalance);
        currentbalancesum[account] = safeadd(currentbalancesum[account],
                                             safedecmul(prebalance,
                                                        inttodec(now  lasttransfertime)));

        
        lasttransfertimestamp[account] = now;
    }

    
    function rolloverfee(address account, uint lasttransfertime, uint prebalance)
        internal
    {
        if (lasttransfertime < feeperiodstarttime) {
            uint timetorollover = inttodec(feeperiodstarttime  lasttransfertime);
            penultimateaveragebalance[account] = lastaveragebalance[account];

            
            if (timetorollover >= lastfeeperiodduration) {
                lastaveragebalance[account] = prebalance;
            } else {
                lastaveragebalance[account] = safedecmul(safeadd(currentbalancesum[account],
                                                                 safedecmul(prebalance, timetorollover)),
                                                         lastfeeperiodduration);
            }

            
            currentbalancesum[account] = 0;
            haswithdrawnlastperiodfees[account] = false;
            lasttransfertimestamp[account] = feeperiodstarttime;
        }
    }

    
    function withdrawfeeentitlement()
        public
        postcheckfeeperiodrollover
    {
        
        require(!nomin.isfrozen(msg.sender));

        
        require(!haswithdrawnlastperiodfees[msg.sender]);

        rolloverfee(msg.sender, lasttransfertimestamp[msg.sender], balanceof[msg.sender]);
        uint feesowed = safedecmul(safedecmul(lastaveragebalance[msg.sender],
                                              lastfeescollected),
                                   totalsupply);
        nomin.withdrawfee(msg.sender, feesowed);
        haswithdrawnlastperiodfees[msg.sender] = true;
        feeswithdrawn(msg.sender, feesowed);
    }

    
    function setvotedyea(address account, address target)
        public
        onlycourt
    {
        require(vote[account] == court.vote.abstention);
        vote[account] = court.vote.yea;
        votetarget[account] = target;
    }

    
    function setvotednay(address account, address target)
        public
        onlycourt
    {
        require(vote[account] == court.vote.abstention);
        vote[account] = court.vote.nay;
        votetarget[account] = target;
    }

    
    function cancelvote(address account, address target)
        public
        onlycourt
    {
        require(votetarget[account] == target);
        vote[account] = court.vote.abstention;
        votetarget[account] = 0;
    }


    

    
    modifier postcheckfeeperiodrollover
    {
        _;
        uint duration = now  feeperiodstarttime;
        if (targetfeeperioddurationseconds <= duration) {
            lastfeescollected = nomin.feepool();
            lastfeeperiodduration = inttodec(duration);
            feeperiodstarttime = now;
        }
    }

    modifier onlycourt
    {
        require(court(msg.sender) == court);
        _;
    }


    

    event feeperioddurationupdated(uint duration);

    event feeswithdrawn(address indexed account, uint fees);

}
