

pragma solidity ^0.4.19;


import ;
import ;
import ;
import ;


contract court is owned, safedecimalmath {

    

    
    havven havven;
    ethernomin nomin;

    
    
    uint minstandingbalance = 100 * unit;

    
    
    uint votingperiod = 1 weeks;
    uint constant minvotingperiod = 3 days;
    uint constant maxvotingperiod = 4 weeks;

    
    
    
    uint confirmationperiod = 1 weeks;
    uint constant minconfirmationperiod = 1 days;
    uint constant maxconfirmationperiod = 2 weeks;

    
    
    
    uint requiredparticipation = 3 * unit / 10;
    uint constant minrequiredparticipation = unit / 10;

    
    
    
    uint requiredmajority = (2 * unit) / 3;
    uint constant minrequiredmajority = unit / 2;

    
    
    
    
    
    
    mapping(address => uint) public votestarttimes;

    
    
    
    mapping(address => uint) public votesfor;
    mapping(address => uint) public votesagainst;

    
    
    
    
    
    mapping(address => uint) voteweight;

    
    
    
    
    enum vote {abstention, yea, nay}

    
    
    
    mapping(address => vote) public uservote;
    
    mapping(address => address) public votetarget;

    

    function court(havven _havven, ethernomin _nomin, address _owner)
        owned(_owner)
        public
    {
        havven = _havven;
        nomin = _nomin;
    }


    

    function setminstandingbalance(uint balance)
        public
        onlyowner
    {
        
        
        
        minstandingbalance = balance;
        minstandingbalanceupdated(balance);
    }

    function setvotingperiod(uint duration)
        public
        onlyowner
    {
        require(minvotingperiod <= duration &&
                duration <= maxvotingperiod);
        
        
        require(duration <= havven.targetfeeperioddurationseconds());
        votingperiod = duration;
        votingperiodupdated(duration);
    }

    function setconfirmationperiod(uint duration)
        public
        onlyowner
    {
        require(minconfirmationperiod <= duration &&
                duration <= maxconfirmationperiod);
        confirmationperiod = duration;
        confirmationperiodupdated(duration);
    }

    function setrequiredparticipation(uint fraction)
        public
        onlyowner
    {
        require(minrequiredparticipation <= fraction);
        requiredparticipation = fraction;
        requiredparticipationupdated(fraction);
    }

    function setrequiredmajority(uint fraction)
        public
        onlyowner
    {
        require(minrequiredmajority <= fraction);
        requiredmajority = fraction;
        requiredmajorityupdated(fraction);
    }


    


    function hasvoted(address account)
        public
        view
        returns (bool)
    {
        return uservote[account] != court.vote.abstention;
    }

    
    function voting(address target)
        public
        view
        returns (bool)
    {
        
        
        return now < votestarttimes[target] + votingperiod;
    }

    
    function confirming(address target)
        public
        view
        returns (bool)
    {
        uint starttime = votestarttimes[target];
        return starttime + votingperiod <= now &&
               now < starttime + votingperiod + confirmationperiod;
    }

    
    function waiting(address target)
        public
        view
        returns (bool)
    {
        return votestarttimes[target] + votingperiod + confirmationperiod <= now;
    }

    
    function votepasses(address target)
        public
        view
        returns (bool)
    {
        uint yeas = votesfor[target];
        uint nays = votesagainst[target];
        uint totalvotes = yeas + nays;

        if (totalvotes == 0) {
            return false;
        }

        uint participation = safedecdiv(totalvotes, havven.totalsupply());
        uint fractioninfavour = safedecdiv(yeas, totalvotes);

        
        
        return participation > requiredparticipation &&
               fractioninfavour > requiredmajority;
    }


    

    
    function beginconfiscationaction(address target)
        public
    {
        
        require((havven.balanceof(msg.sender) > minstandingbalance) ||
                msg.sender == owner);

        
        
        require(votingperiod <= havven.targetfeeperioddurationseconds());

        
        require(waiting(target));

        
        require(!nomin.isfrozen(target));

        votestarttimes[target] = now;
        votesfor[target] = 0;
        votesagainst[target] = 0;
        confiscationvote(msg.sender, target);
    }

    
    function votefor(address target)
        public
    {
        
        
        require(voting(target));

        
        require(!hasvoted(msg.sender));

        uint weight;
        
        
        
        if (votestarttimes[target] < havven.feeperiodstarttime()) {
            weight = havven.penultimateaveragebalance(msg.sender);
        } else {
            weight = havven.lastaveragebalance(msg.sender);
        }

        
        require(weight > 0);

        
        
        
        setvotedyea(msg.sender, target);
        voteweight[msg.sender] = weight;
        votesfor[msg.sender] += weight;
        votefor(msg.sender, target, weight);
    }

    
    function voteagainst(address target)
        public
    {
        
        
        require(voting(target));

        
        require(!hasvoted(msg.sender));

        uint weight;
        
        
        
        if (votestarttimes[target] < havven.feeperiodstarttime()) {
            weight = havven.penultimateaveragebalance(msg.sender);
        } else {
            weight = havven.lastaveragebalance(msg.sender);
        }

        
        require(weight > 0);

        
        
        
        setvotednay(msg.sender, target);
        voteweight[msg.sender] = weight;
        votesagainst[msg.sender] += weight;
        voteagainst(msg.sender, target, weight);
    }

    
    function cancelvote(address target)
        public
    {
        
        
        
        
        require(!confirming(target));

        
        if (voting(target)) {
            
            vote vote = uservote[msg.sender];

            if (vote == vote.yea) {
                votesfor[msg.sender] = voteweight[msg.sender];
            }
            else if (vote == vote.nay) {
                votesagainst[msg.sender] = voteweight[msg.sender];
            } else {
                
                return;
            }

            
            voteweight[msg.sender] = 0;
            cancelledvote(msg.sender, target);
        }

        
        
        
        cancelvote(msg.sender, target);
    }

    
    function closevote(address target)
        public
    {
        require((confirming(target) && !votepasses(target)) || waiting(target));

        votestarttimes[target] = 0;
        votesfor[target] = 0;
        votesagainst[target] = 0;
        voteclosed(target);
    }

    
    function approve(address target)
        public
        onlyowner
    {
        require(confirming(target));
        require(votepasses(target));

        nomin.confiscatebalance(target);
        votestarttimes[target] = 0;
        votesfor[target] = 0;
        votesagainst[target] = 0;
        voteclosed(target);
        confiscationapproval(target);
    }

    
    function veto(address target)
        public
        onlyowner
    {
        require(!waiting(target));
        votestarttimes[target] = 0;
        votesfor[target] = 0;
        votesagainst[target] = 0;
        voteclosed(target);
        veto(target);
    }



    
    function setvotedyea(address account, address target)
        internal
    {
        require(uservote[account] == court.vote.abstention);
        uservote[account] = court.vote.yea;
        votetarget[account] = target;
    }

    
    function setvotednay(address account, address target)
        internal
    {
        require(uservote[account] == court.vote.abstention);
        uservote[account] = court.vote.nay;
        votetarget[account] = target;
    }

    
    function cancelvote(address account, address target)
        internal
    {
        require(votetarget[account] == target);
        uservote[account] = court.vote.abstention;
        votetarget[account] = 0;
    }

    

    event minstandingbalanceupdated(uint balance);

    event votingperiodupdated(uint duration);

    event confirmationperiodupdated(uint duration);

    event requiredparticipationupdated(uint fraction);

    event requiredmajorityupdated(uint fraction);

    event confiscationvote(address indexed initiator, address indexed target);

    event votefor(address indexed account, address indexed target, uint balance);

    event voteagainst(address indexed account, address indexed target, uint balance);

    event cancelledvote(address indexed account, address indexed target);

    event voteclosed(address indexed target);

    event veto(address indexed target);

    event confiscationapproval(address indexed target);
}
