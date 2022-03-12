

import ;
import ;
import ;
import ;

pragma solidity ^0.4.19;

contract havvenescrow is owned, safedecimalmath {    
    
    havven public havven;
    ethernomin public nomin;

    
    
    mapping(address => uint[2][]) public vestingschedules;

    
    mapping(address => uint) public totalvestedaccountbalance;

    
    uint public totalvestedbalance;


    function havvenescrow(address _owner, havven _havven, ethernomin _nomin)
        owned(_owner)
        public
    {
        havven = _havven;
        nomin = _nomin;
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
        public
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
        public
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
        public
        view
        returns (uint)
    {
        uint index = getnextvestingindex(account);
        if (index == numvestingentries(account)) {
            return 0;
        }
        return getvestingquantity(account, index);
    }

    
    function feepool()
        public
        view
        returns (uint)
    {
        return nomin.balanceof(this);
    }

    function sethavven(havven newhavven)
        public
        onlyowner
    {
        havven = newhavven;
        havvenupdated(newhavven);
    }

    function setnomin(ethernomin newnomin)
        public
        onlyowner
    {
        nomin = newnomin;
        nominupdated(newnomin);
    } 

    
    function remitfees()
        public
    {
        
        
        require(havven(msg.sender) == havven);
        uint feebalance = feepool();
        
        if (feebalance != 0) {
            nomin.donatetofeepool(feepool());
        }
    }

    
    function withdrawfeepool()
        public
        onlyowner
    {
        havven.withdrawfeeentitlement();
        contractfeeswithdrawn(now, feepool());
    }

    
    function withdrawfees()
        public
    {
        
        if (!havven.haswithdrawnlastperiodfees(this)) {
            withdrawfeepool();
            
            
            
            contractfeeswithdrawn(now, feepool());
        }
        
        uint entitlement = nomin.pricetospend(safedecdiv(safedecmul(totalvestedaccountbalance[msg.sender], feepool()), totalvestedbalance));
        if (entitlement != 0) {
            nomin.transfer(msg.sender, entitlement);
            feeswithdrawn(msg.sender, msg.sender, now, entitlement);
        }
    }

    
    function purgeaccount(address account)
        onlyowner
        public
    {
        delete vestingschedules[account];
        totalvestedbalance = safesub(totalvestedbalance, totalvestedaccountbalance[account]);
        totalvestedaccountbalance[account] = 0;
    }

    
    function withdrawhavvens(uint quantity)
        onlyowner
        external
    {
        havven.transfer(havven, quantity);
    }

    
    function appendvestingentry(address account, uint time, uint quantity)
        onlyowner
        public
    {
        
        require(now < time);
        require(quantity != 0);

        if (vestingschedules[account].length == 0) {
            totalvestedaccountbalance[account] = quantity;
        } else {
            
            
            require(getvestingtime(account, numvestingentries(account)  1) < time);
            totalvestedaccountbalance[account] = safeadd(totalvestedaccountbalance[account], quantity);
        }

        vestingschedules[account].push([time, quantity]);
        totalvestedbalance = safeadd(totalvestedbalance, quantity);
    }

    
    function addregularvestingschedule(address account, uint conclusion_time, uint quantity, uint vesting_periods)
        onlyowner
        public
    {
        
        uint time_period = safesub(conclusion_time, now);
        
        uint item_quantity = safediv(quantity, vesting_periods);
        uint quant_sum = safemul(item_quantity, (vesting_periods1));
        uint period_length = safediv(time_period, vesting_periods); 

        for (uint i = 1; i < vesting_periods; i++) {
            uint item_time_period = safemul(i, period_length);
            appendvestingentry(account, safeadd(now, item_time_period), item_quantity);
        }
        appendvestingentry(account, conclusion_time, safesub(quantity, quant_sum));
    }

    
    function vest() 
        public
    {
        uint total = 0;
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
            vested(msg.sender, msg.sender, now, total);
        }
    }

    event havvenupdated(address newhavven);

    event nominupdated(address newnomin);

    event contractfeeswithdrawn(uint time, uint value);

    event feeswithdrawn(address recipient, address indexed recipientindex, uint time, uint value);

    event vested(address beneficiary, address indexed beneficiaryindex, uint time, uint value);

}