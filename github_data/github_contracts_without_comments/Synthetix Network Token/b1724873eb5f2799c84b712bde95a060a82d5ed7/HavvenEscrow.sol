

pragma solidity 0.4.21;


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
        emit havvenupdated(_havven);
    }


    

    
    function balanceof(address account)
        public
        view
        returns (uint)
    {
        return totalvestedaccountbalance[account];
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

    
    function addvestingschedule(address account, uint[] times, uint[] quantities)
        external
        onlyowner
        setupfunction
    {
        for (uint i = 0; i < times.length; i++) {
            appendvestingentry(account, times[i], quantities[i]);
        }

    }

    
    function vest() 
        external
    {
        uint numentries = numvestingentries(msg.sender);
        uint total;
        for (uint i = 0; i < numentries; i++) {
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
            emit vested(msg.sender, msg.sender,
                   now, total);
        }
    }


    

    event havvenupdated(address newhavven);

    event vested(address beneficiary, address indexed beneficiaryindex, uint time, uint value);
}
