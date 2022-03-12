

pragma solidity ^0.4.20;


import ;
import ;
import ;
import ;
import ;


contract havvenescrow is owned, limitedsetup(8 weeks), safedecimalmath {    
    
    havven public havven;

    
    
    mapping(address => uint[2][]) public vestingschedules;

    
    mapping(address => uint) public totalvestedaccountbalance;

    
    uint public totalvestedbalance;


    

    function havvenescrow(address _owner, havven _havven)
        owned(_owner)
        public
    {
        havven = _havven;
    }


    

    function sethavven(havven _havven)
        external
        onlyowner
    {
        havven = _havven;
        havvenupdated(_havven);
    }


    

    
    function numvestingentries(address account)
        public
        view
        returns (uint)
    {
        return vestingschedules[account].length;
    }

    
    function getvestingscheduleentry(address account, uint index)
        public
        view
        returns (uint[2])
    {
        return vestingschedules[account][index];
    }

    
    function getvestingtime(address account, uint index)
        public
        view
        returns (uint)
    {
        return vestingschedules[account][index][0];
    }

    
    function getvestingquantity(address account, uint index)
        public
        view
        returns (uint)
    {
        return vestingschedules[account][index][1];
    }

    
    function getnextvestingindex(address account)
        public
        view
        returns (uint)
    {
        uint len = numvestingentries(account);
        for (uint i = 0; i < len; i++) {
            if (getvestingtime(account, i) != 0) {
                return i;
            }
        }
        return len;
    }

    
    function getnextvestingentry(address account)
        external
        view
        returns (uint[2])
    {
        uint index = getnextvestingindex(account);
        if (index == numvestingentries(account)) {
            return [uint(0), 0];
        }
        return getvestingscheduleentry(account, index);
    }

    
    function getnextvestingtime(address account)
        external
        view
        returns (uint)
    {
        uint index = getnextvestingindex(account);
        if (index == numvestingentries(account)) {
            return 0;
        }
        return getvestingtime(account, index);
    }

    
    function getnextvestingquantity(address account)
        external
        view
        returns (uint)
    {
        uint index = getnextvestingindex(account);
        if (index == numvestingentries(account)) {
            return 0;
        }
        return getvestingquantity(account, index);
    }


    

    
    function withdrawhavvens(uint quantity)
        external
        onlyowner
        setupfunction
    {
        havven.transfer(havven, quantity);
    }

    
    function purgeaccount(address account)
        external
        onlyowner
        setupfunction
    {
        delete vestingschedules[account];
        totalvestedbalance = safesub(totalvestedbalance, totalvestedaccountbalance[account]);
        delete totalvestedaccountbalance[account];
        schedulepurged(account);
    }

    
    function appendvestingentry(address account, uint time, uint quantity)
        public
        onlyowner
        setupfunction
    {
        
        require(now < time);
        require(quantity != 0);
        totalvestedbalance = safeadd(totalvestedbalance, quantity);
        require(totalvestedbalance <= havven.balanceof(this));

        if (vestingschedules[account].length == 0) {
            totalvestedaccountbalance[account] = quantity;
        } else {
            
            
            require(getvestingtime(account, numvestingentries(account)  1) < time);
            totalvestedaccountbalance[account] = safeadd(totalvestedaccountbalance[account], quantity);
        }

        vestingschedules[account].push([time, quantity]);
    }

    
    function addregularvestingschedule(address account, uint conclusiontime,
                                       uint totalquantity, uint vestingperiods)
        external
        onlyowner
        setupfunction
    {
        
        uint totalduration = safesub(conclusiontime, now);

        
        uint periodquantity = safediv(totalquantity, vestingperiods);
        uint periodduration = safediv(totalduration, vestingperiods);

        
        for (uint i = 1; i < vestingperiods; i++) {
            uint periodconclusiontime = safeadd(now, safemul(i, periodduration));
            appendvestingentry(account, periodconclusiontime, periodquantity);
        }

        
        uint finalperiodquantity = safesub(totalquantity, safemul(periodquantity, (vestingperiods  1)));
        appendvestingentry(account, conclusiontime, finalperiodquantity);
    }

    
    function vest() 
        external
    {
        uint total;
        for (uint i = 0; i < numvestingentries(msg.sender); i++) {
            uint time = getvestingtime(msg.sender, i);
            
            if (time > now) {
                break;
            }
            uint qty = getvestingquantity(msg.sender, i);
            if (qty == 0) {
                continue;
            }

            vestingschedules[msg.sender][i] = [0, 0];
            total = safeadd(total, qty);
            totalvestedaccountbalance[msg.sender] = safesub(totalvestedaccountbalance[msg.sender], qty);
        }

        if (total != 0) {
            totalvestedbalance = safesub(totalvestedbalance, total);
            havven.transfer(msg.sender, total);
            vested(msg.sender, msg.sender,
                   now, total);
        }
    }


    

    event havvenupdated(address newhavven);

    event nominupdated(address newnomin);

    event contractfeeswithdrawn(uint time, uint value);

    event feeswithdrawn(address recipient, address indexed recipientindex, uint time, uint value);

    event vested(address beneficiary, address indexed beneficiaryindex, uint time, uint value);

    event schedulepurged(address account);
}
