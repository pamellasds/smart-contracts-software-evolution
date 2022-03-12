

pragma solidity ^0.4.19;


import ;
import ;
import ;
import ;


contract court is owned, safedecimalmath {

    

    
    havven havven;
    ethernomin nomin;

    
    
    uint public minstandingbalance = 100 * unit;

    
    
    uint public votingperiod = 1 weeks;
    uint constant minvotingperiod = 3 days;
    uint constant maxvotingperiod = 4 weeks;

    
    
    
    uint public confirmationperiod = 1 weeks;
    uint constant minconfirmationperiod = 1 days;
    uint constant maxconfirmationperiod = 2 weeks;

    
    
    
    uint public requiredparticipation = 3 * unit / 10;
    uint constant minrequiredparticipation = unit / 10;

    
    
    
    uint public requiredmajority = (2 * unit) / 3;
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
    }

    function setvotingperiod(uint duration)
        public
        onlyowner
    {
        require(minvotingperiod <= duration &&
                duration <= maxvotingperiod);
        
        
        require(duration <= havven.targetfeeperioddurationseconds());
        votingperiod = duration;
    }

    function setconfirmationperiod(uint duration)
        public
        onlyowner
    {
        require(minconfirmationperiod <= duration &&
                duration <= maxconfirmationperiod);
        confirmationperiod = duration;
    }

    function setrequiredparticipation(uint fraction)
        public
        onlyowner
    {
        require(minrequiredparticipation <= fraction);
        requiredparticipation = fraction;
    }

    function setrequiredmajority(uint fraction)
        public
        onlyowner
    {
        require(minrequiredmajority <= fraction);
        requiredmajority = fraction;
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


    

    
    function beginconfiscationmotion(address target)
        public
    {
        
        require((havven.balanceof(msg.sender) >= minstandingbalance) ||
                msg.sender == owner);

        
        
        require(votingperiod <= havven.targetfeeperioddurationseconds());

        
        require(waiting(target));

        
        require(!nomin.isfrozen(target));

        votestarttimes[target] = now;
        votesfor[target] = 0;
        votesagainst[target] = 0;
        confiscationvote(msg.sender, msg.sender, target, target);
    }

    
    function votesetup(address target)
        internal
        returns (uint)
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

        return weight;
    }

    
    function votefor(address target)
        public
    {
        uint weight = votesetup(target);
        setvotedyea(msg.sender, target);
        voteweight[msg.sender] = weight;
        votesfor[target] += weight;
        votefor(msg.sender, msg.sender, target, target, weight);
    }

    
    function voteagainst(address target)
        public
    {
        uint weight = votesetup(target);
        setvotednay(msg.sender, target);
        voteweight[msg.sender] = weight;
        votesagainst[target] += weight;
        voteagainst(msg.sender, msg.sender, target, target, weight);
    }

    
    function cancelvote(address target)
        public
    {
        
        
        
        
        require(!confirming(target));

        
        if (voting(target)) {
            
            vote vote = uservote[msg.sender];

            if (vote == vote.yea) {
                votesfor[target] = voteweight[msg.sender];
            }
            else if (vote == vote.nay) {
                votesagainst[target] = voteweight[msg.sender];
            } else {
                
                return;
            }

            
            voteweight[msg.sender] = 0;
            cancelledvote(msg.sender, msg.sender, target, target);
        }

        
        
        require(votetarget[msg.sender] == target);
        uservote[msg.sender] = court.vote.abstention;
        votetarget[msg.sender] = 0;
    }

    
    function closevote(address target)
        public
    {
        require((confirming(target) && !votepasses(target)) || waiting(target));

        votestarttimes[target] = 0;
        votesfor[target] = 0;
        votesagainst[target] = 0;
        voteclosed(target, target);
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
        voteclosed(target, target);
        confiscationapproval(target, target);
    }

    
    function veto(address target)
        public
        onlyowner
    {
        require(!waiting(target));
        votestarttimes[target] = 0;
        votesfor[target] = 0;
        votesagainst[target] = 0;
        voteclosed(target, target);
        veto(target, target);
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

    

    event confiscationvote(address initator, address indexed initiatorindex, address target, address indexed targetindex);

    event votefor(address account, address indexed accountindex, address target, address indexed targetindex, uint balance);

    event voteagainst(address account, address indexed accountindex, address target, address indexed targetindex, uint balance);

    event cancelledvote(address account, address indexed accountindex, address target, address indexed targetindex);

    event voteclosed(address target, address indexed targetindex);

    event veto(address target, address indexed targetindex);

    event confiscationapproval(address target, address indexed targetindex);
}
