

pragma solidity 0.4.25;


import ;
import ;
import ;
import ;


contract rewardescrow is owned {

    using safemath for uint;

    
    isynthetix public synthetix;

    ifeepool public feepool;

    
    mapping(address => uint[2][]) public vestingschedules;

    
    mapping(address => uint) public totalescrowedaccountbalance;

    
    mapping(address => uint) public totalvestedaccountbalance;

    
    uint public totalescrowedbalance;

    uint constant time_index = 0;
    uint constant quantity_index = 1;

    
    uint constant public max_vesting_entries = 52*5;


    

    constructor(address _owner, isynthetix _synthetix, ifeepool _feepool)
    owned(_owner)
    public
    {
        synthetix = _synthetix;
        feepool = _feepool;
    }


    

    
    function setsynthetix(isynthetix _synthetix)
    external
    onlyowner
    {
        synthetix = _synthetix;
        emit synthetixupdated(_synthetix);
    }

    
    function setfeepool(ifeepool _feepool)
        external
        onlyowner
    {
        feepool = _feepool;
        emit feepoolupdated(_feepool);
    }


    

    
    function balanceof(address account)
    public
    view
    returns (uint)
    {
        return totalescrowedaccountbalance[account];
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
        return getvestingscheduleentry(account,index)[time_index];
    }

    
    function getvestingquantity(address account, uint index)
    public
    view
    returns (uint)
    {
        return getvestingscheduleentry(account,index)[quantity_index];
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
    external
    view
    returns (uint)
    {
        return getnextvestingentry(account)[time_index];
    }

    
    function getnextvestingquantity(address account)
    external
    view
    returns (uint)
    {
        return getnextvestingentry(account)[quantity_index];
    }

    
    function checkaccountschedule(address account)
        public
        view
        returns (uint[520])
    {
        uint[520] memory _result;
        uint schedules = numvestingentries(account);
        for (uint i = 0; i < schedules; i++) {
            uint[2] memory pair = getvestingscheduleentry(account, i);
            _result[i*2] = pair[0];
            _result[i*2 + 1] = pair[1];
        }
        return _result;
    }


    

    
    function appendvestingentry(address account, uint quantity)
    public
    onlyfeepool
    {
        
        require(quantity != 0, );

        
        totalescrowedbalance = totalescrowedbalance.add(quantity);
        require(totalescrowedbalance <= synthetix.balanceof(this), );

        
        uint schedulelength = vestingschedules[account].length;
        require(schedulelength <= max_vesting_entries, );

        
        uint time = now + 52 weeks;

        if (schedulelength == 0) {
            totalescrowedaccountbalance[account] = quantity;
        } else {
            
            require(getvestingtime(account, numvestingentries(account)  1) < time, );
            totalescrowedaccountbalance[account] = totalescrowedaccountbalance[account].add(quantity);
        }

        vestingschedules[account].push([time, quantity]);

        emit vestingentrycreated(account, now, quantity);
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
            total = total.add(qty);
        }

        if (total != 0) {
            totalescrowedbalance = totalescrowedbalance.sub(total);
            totalescrowedaccountbalance[msg.sender] = totalescrowedaccountbalance[msg.sender].sub(total);
            totalvestedaccountbalance[msg.sender] = totalvestedaccountbalance[msg.sender].add(total);
            synthetix.transfer(msg.sender, total);
            emit vested(msg.sender, now, total);
        }
    }

    

    modifier onlyfeepool() {
        bool isfeepool = msg.sender == address(feepool);

        require(isfeepool, );
        _;
    }


    

    event synthetixupdated(address newsynthetix);

    event feepoolupdated(address newfeepool);

    event vested(address indexed beneficiary, uint time, uint value);

    event vestingentrycreated(address indexed beneficiary, uint time, uint value);

}
