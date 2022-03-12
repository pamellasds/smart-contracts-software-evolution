pragma solidity ^0.5.16;


import ;
import ;


import ;


import ;
import ;
import ;



contract rewardescrow is owned, irewardescrow {
    using safemath for uint;

    
    isynthetix public synthetix;

    ifeepool public feepool;

    
    mapping(address => uint[2][]) public vestingschedules;

    
    mapping(address => uint) public totalescrowedaccountbalance;

    
    mapping(address => uint) public totalvestedaccountbalance;

    
    uint public totalescrowedbalance;

    uint internal constant time_index = 0;
    uint internal constant quantity_index = 1;

    
    uint public constant max_vesting_entries = 52 * 5;

    

    constructor(
        address _owner,
        isynthetix _synthetix,
        ifeepool _feepool
    ) public owned(_owner) {
        synthetix = _synthetix;
        feepool = _feepool;
    }

    

    
    function setsynthetix(isynthetix _synthetix) external onlyowner {
        synthetix = _synthetix;
        emit synthetixupdated(address(_synthetix));
    }

    
    function setfeepool(ifeepool _feepool) external onlyowner {
        feepool = _feepool;
        emit feepoolupdated(address(_feepool));
    }

    

    
    function balanceof(address account) public view returns (uint) {
        return totalescrowedaccountbalance[account];
    }

    function _numvestingentries(address account) internal view returns (uint) {
        return vestingschedules[account].length;
    }

    
    function numvestingentries(address account) external view returns (uint) {
        return vestingschedules[account].length;
    }

    
    function getvestingscheduleentry(address account, uint index) public view returns (uint[2] memory) {
        return vestingschedules[account][index];
    }

    
    function getvestingtime(address account, uint index) public view returns (uint) {
        return getvestingscheduleentry(account, index)[time_index];
    }

    
    function getvestingquantity(address account, uint index) public view returns (uint) {
        return getvestingscheduleentry(account, index)[quantity_index];
    }

    
    function getnextvestingindex(address account) public view returns (uint) {
        uint len = _numvestingentries(account);
        for (uint i = 0; i < len; i++) {
            if (getvestingtime(account, i) != 0) {
                return i;
            }
        }
        return len;
    }

    
    function getnextvestingentry(address account) public view returns (uint[2] memory) {
        uint index = getnextvestingindex(account);
        if (index == _numvestingentries(account)) {
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

    
    function checkaccountschedule(address account) public view returns (uint[520] memory) {
        uint[520] memory _result;
        uint schedules = _numvestingentries(account);
        for (uint i = 0; i < schedules; i++) {
            uint[2] memory pair = getvestingscheduleentry(account, i);
            _result[i * 2] = pair[0];
            _result[i * 2 + 1] = pair[1];
        }
        return _result;
    }

    

    function _appendvestingentry(address account, uint quantity) internal {
        
        require(quantity != 0, );

        
        totalescrowedbalance = totalescrowedbalance.add(quantity);
        require(
            totalescrowedbalance <= ierc20(address(synthetix)).balanceof(address(this)),
            
        );

        
        uint schedulelength = vestingschedules[account].length;
        require(schedulelength <= max_vesting_entries, );

        
        uint time = now + 52 weeks;

        if (schedulelength == 0) {
            totalescrowedaccountbalance[account] = quantity;
        } else {
            
            require(
                getvestingtime(account, schedulelength  1) < time,
                
            );
            totalescrowedaccountbalance[account] = totalescrowedaccountbalance[account].add(quantity);
        }

        vestingschedules[account].push([time, quantity]);

        emit vestingentrycreated(account, now, quantity);
    }

    
    function appendvestingentry(address account, uint quantity) external onlyfeepool {
        _appendvestingentry(account, quantity);
    }

    
    function vest() external {
        uint numentries = _numvestingentries(msg.sender);
        uint total;
        for (uint i = 0; i < numentries; i++) {
            uint time = getvestingtime(msg.sender, i);
            
            if (time > now) {
                break;
            }
            uint qty = getvestingquantity(msg.sender, i);
            if (qty > 0) {
                vestingschedules[msg.sender][i] = [0, 0];
                total = total.add(qty);
            }
        }

        if (total != 0) {
            totalescrowedbalance = totalescrowedbalance.sub(total);
            totalescrowedaccountbalance[msg.sender] = totalescrowedaccountbalance[msg.sender].sub(total);
            totalvestedaccountbalance[msg.sender] = totalvestedaccountbalance[msg.sender].add(total);
            ierc20(address(synthetix)).transfer(msg.sender, total);
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
