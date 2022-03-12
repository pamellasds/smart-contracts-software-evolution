

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;



contract synthetixescrow is owned, limitedsetup(8 weeks) {
    using safemath for uint;

    
    isynthetix public synthetix;

    
    mapping(address => uint[2][]) public vestingschedules;

    
    mapping(address => uint) public totalvestedaccountbalance;

    
    uint public totalvestedbalance;

    uint constant time_index = 0;
    uint constant quantity_index = 1;

    
    uint constant max_vesting_entries = 20;

    

    constructor(address _owner, isynthetix _synthetix) public owned(_owner) {
        synthetix = _synthetix;
    }

    

    function setsynthetix(isynthetix _synthetix) external onlyowner {
        synthetix = _synthetix;
        emit synthetixupdated(_synthetix);
    }

    

    
    function balanceof(address account) public view returns (uint) {
        return totalvestedaccountbalance[account];
    }

    
    function numvestingentries(address account) public view returns (uint) {
        return vestingschedules[account].length;
    }

    
    function getvestingscheduleentry(address account, uint index) public view returns (uint[2]) {
        return vestingschedules[account][index];
    }

    
    function getvestingtime(address account, uint index) public view returns (uint) {
        return getvestingscheduleentry(account, index)[time_index];
    }

    
    function getvestingquantity(address account, uint index) public view returns (uint) {
        return getvestingscheduleentry(account, index)[quantity_index];
    }

    
    function getnextvestingindex(address account) public view returns (uint) {
        uint len = numvestingentries(account);
        for (uint i = 0; i < len; i++) {
            if (getvestingtime(account, i) != 0) {
                return i;
            }
        }
        return len;
    }

    
    function getnextvestingentry(address account) public view returns (uint[2]) {
        uint index = getnextvestingindex(account);
        if (index == numvestingentries(account)) {
            return [uint(0), 0];
        }
        return getvestingscheduleentry(account, index);
    }

    
    function getnextvestingtime(address account) external view returns (uint) {
        return getnextvestingentry(account)[time_index];
    }

    
    function getnextvestingquantity(address account) external view returns (uint) {
        return getnextvestingentry(account)[quantity_index];
    }

    

    
    function withdrawsynthetix(uint quantity) external onlyowner onlyduringsetup {
        synthetix.transfer(synthetix, quantity);
    }

    
    function purgeaccount(address account) external onlyowner onlyduringsetup {
        delete vestingschedules[account];
        totalvestedbalance = totalvestedbalance.sub(totalvestedaccountbalance[account]);
        delete totalvestedaccountbalance[account];
    }

    
    function appendvestingentry(address account, uint time, uint quantity) public onlyowner onlyduringsetup {
        
        require(now < time, );
        require(quantity != 0, );

        
        totalvestedbalance = totalvestedbalance.add(quantity);
        require(
            totalvestedbalance <= synthetix.balanceof(this),
            
        );

        
        uint schedulelength = vestingschedules[account].length;
        require(schedulelength <= max_vesting_entries, );

        if (schedulelength == 0) {
            totalvestedaccountbalance[account] = quantity;
        } else {
            
            require(
                getvestingtime(account, numvestingentries(account)  1) < time,
                
            );
            totalvestedaccountbalance[account] = totalvestedaccountbalance[account].add(quantity);
        }

        vestingschedules[account].push([time, quantity]);
    }

    
    function addvestingschedule(address account, uint[] times, uint[] quantities) external onlyowner onlyduringsetup {
        for (uint i = 0; i < times.length; i++) {
            appendvestingentry(account, times[i], quantities[i]);
        }
    }

    
    function vest() external {
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
            total = total.add(qty);
        }

        if (total != 0) {
            totalvestedbalance = totalvestedbalance.sub(total);
            totalvestedaccountbalance[msg.sender] = totalvestedaccountbalance[msg.sender].sub(total);
            synthetix.transfer(msg.sender, total);
            emit vested(msg.sender, now, total);
        }
    }

    

    event synthetixupdated(address newsynthetix);

    event vested(address indexed beneficiary, uint time, uint value);
}
