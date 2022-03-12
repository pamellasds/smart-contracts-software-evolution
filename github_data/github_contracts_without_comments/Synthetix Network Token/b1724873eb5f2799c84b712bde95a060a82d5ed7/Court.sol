

pragma solidity 0.4.21;


import ;
import ;
import ;
import ;



contract court is owned, safedecimalmath {

    

    
    havven public havven;
    ethernomin public nomin;

    
    uint public minstandingbalance = 100 * unit;

    
    uint public votingperiod = 1 weeks;
    uint constant min_voting_period = 3 days;
    uint constant max_voting_period = 4 weeks;

    
    uint public confirmationperiod = 1 weeks;
    uint constant min_confirmation_period = 1 days;
    uint constant max_confirmation_period = 2 weeks;

    
    uint public requiredparticipation = 3 * unit / 10;
    uint constant min_required_participation = unit / 10;

    
    uint public requiredmajority = (2 * unit) / 3;
    uint constant min_required_majority = unit / 2;

    
    uint nextmotionid = 1;

    
    mapping(uint => address) public motiontarget;

    
    mapping(address => uint) public targetmotionid;

    
    mapping(uint => uint) public motionstarttime;

    
    mapping(uint => uint) public votesfor;
    mapping(uint => uint) public votesagainst;

    
    mapping(address => mapping(uint => uint)) voteweight;

    
    enum vote {abstention, yea, nay}

    
    mapping(address => mapping(uint => vote)) public vote;


    

    
    function court(havven _havven, ethernomin _nomin, address _owner)
        owned(_owner)
        public
    {
        havven = _havven;
        nomin = _nomin;
    }


    

    
    function setminstandingbalance(uint balance)
        external
        onlyowner
    {
        
        minstandingbalance = balance;
    }

    
    function setvotingperiod(uint duration)
        external
        onlyowner
    {
        require(min_voting_period <= duration &&
                duration <= max_voting_period);
        
        require(duration <= havven.targetfeeperioddurationseconds());
        votingperiod = duration;
    }

    function setconfirmationperiod(uint duration)
        external
        onlyowner
    {
        require(min_confirmation_period <= duration &&
                duration <= max_confirmation_period);
        confirmationperiod = duration;
    }

    function setrequiredparticipation(uint fraction)
        external
        onlyowner
    {
        require(min_required_participation <= fraction);
        requiredparticipation = fraction;
    }

    function setrequiredmajority(uint fraction)
        external
        onlyowner
    {
        require(min_required_majority <= fraction);
        requiredmajority = fraction;
    }


    

    
    function motionvoting(uint motionid)
        public
        view
        returns (bool)
    {
        
        return now < motionstarttime[motionid] + votingperiod;
    }

    
    function motionconfirming(uint motionid)
        public
        view
        returns (bool)
    {
        
        uint starttime = motionstarttime[motionid];
        return starttime + votingperiod <= now &&
               now < starttime + votingperiod + confirmationperiod;
    }

    
    function motionwaiting(uint motionid)
        public
        view
        returns (bool)
    {
        
        return motionstarttime[motionid] + votingperiod + confirmationperiod <= now;
    }

    
    function motionpasses(uint motionid)
        public
        view
        returns (bool)
    {
        uint yeas = votesfor[motionid];
        uint nays = votesagainst[motionid];
        uint totalvotes = safeadd(yeas, nays);

        if (totalvotes == 0) {
            return false;
        }

        uint participation = safediv_dec(totalvotes, havven.totalsupply());
        uint fractioninfavour = safediv_dec(yeas, totalvotes);

        
        return participation > requiredparticipation &&
               fractioninfavour > requiredmajority;
    }

    function hasvoted(address account, uint motionid)
        public
        view
        returns (bool)
    {
        return vote[account][motionid] != vote.abstention;
    }


    

    
    function beginmotion(address target)
        external
        returns (uint)
    {
        
        require((havven.balanceof(msg.sender) >= minstandingbalance) ||
                msg.sender == owner);

        
        require(votingperiod <= havven.targetfeeperioddurationseconds());

        
        require(targetmotionid[target] == 0);

        
        require(!nomin.frozen(target));

        uint motionid = nextmotionid++;
        motiontarget[motionid] = target;
        targetmotionid[target] = motionid;

        motionstarttime[motionid] = now;
        emit motionbegun(msg.sender, msg.sender, target, target, motionid, motionid);

        return motionid;
    }

    
    function setupvote(uint motionid)
        internal
        returns (uint)
    {
        
        require(motionvoting(motionid));

        
        require(!hasvoted(msg.sender, motionid));

        
        require(msg.sender != motiontarget[motionid]);

        
        havven.recomputeaccountlastaveragebalance(msg.sender);

        uint weight;
        
        if (motionstarttime[motionid] < havven.feeperiodstarttime()) {
            weight = havven.penultimateaveragebalance(msg.sender);
        } else {
            weight = havven.lastaveragebalance(msg.sender);
        }

        
        require(weight > 0);

        voteweight[msg.sender][motionid] = weight;

        return weight;
    }

    
    function votefor(uint motionid)
        external
    {
        uint weight = setupvote(motionid);
        vote[msg.sender][motionid] = vote.yea;
        votesfor[motionid] = safeadd(votesfor[motionid], weight);
        emit votedfor(msg.sender, msg.sender, motionid, motionid, weight);
    }

    
    function voteagainst(uint motionid)
        external
    {
        uint weight = setupvote(motionid);
        vote[msg.sender][motionid] = vote.nay;
        votesagainst[motionid] = safeadd(votesagainst[motionid], weight);
        emit votedagainst(msg.sender, msg.sender, motionid, motionid, weight);
    }

    
    function cancelvote(uint motionid)
        external
    {
        
        require(!motionconfirming(motionid));

        vote sendervote = vote[msg.sender][motionid];

        
        require(sendervote != vote.abstention);

        
        if (motionvoting(motionid)) {
            if (sendervote == vote.yea) {
                votesfor[motionid] = safesub(votesfor[motionid], voteweight[msg.sender][motionid]);
            } else {
                
                votesagainst[motionid] = safesub(votesagainst[motionid], voteweight[msg.sender][motionid]);
            }
            
            emit votecancelled(msg.sender, msg.sender, motionid, motionid);
        }

        delete voteweight[msg.sender][motionid];
        delete vote[msg.sender][motionid];
    }

    function _closemotion(uint motionid)
        internal
    {
        delete targetmotionid[motiontarget[motionid]];
        delete motiontarget[motionid];
        delete motionstarttime[motionid];
        delete votesfor[motionid];
        delete votesagainst[motionid];
        emit motionclosed(motionid, motionid);
    }

    
    function closemotion(uint motionid)
        external
    {
        require((motionconfirming(motionid) && !motionpasses(motionid)) || motionwaiting(motionid));
        _closemotion(motionid);
    }

    
    function approvemotion(uint motionid)
        external
        onlyowner
    {
        require(motionconfirming(motionid) && motionpasses(motionid));
        address target = motiontarget[motionid];
        nomin.confiscatebalance(target);
        _closemotion(motionid);
        emit motionapproved(motionid, motionid);
    }

    
    function vetomotion(uint motionid)
        external
        onlyowner
    {
        require(!motionwaiting(motionid));
        _closemotion(motionid);
        emit motionvetoed(motionid, motionid);
    }


    

    event motionbegun(address initiator, address indexed initiatorindex, address target, address indexed targetindex, uint motionid, uint indexed motionidindex);

    event votedfor(address voter, address indexed voterindex, uint motionid, uint indexed motionidindex, uint weight);

    event votedagainst(address voter, address indexed voterindex, uint motionid, uint indexed motionidindex, uint weight);

    event votecancelled(address voter, address indexed voterindex, uint motionid, uint indexed motionidindex);

    event motionclosed(uint motionid, uint indexed motionidindex);

    event motionvetoed(uint motionid, uint indexed motionidindex);

    event motionapproved(uint motionid, uint indexed motionidindex);
}
