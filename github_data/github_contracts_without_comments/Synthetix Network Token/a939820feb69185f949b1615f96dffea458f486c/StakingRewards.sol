pragma solidity ^0.5.16;

import ;
import ;
import ;
import ;
import ;


import ;
import ;
import ;


contract stakingrewards is istakingrewards, rewardsdistributionrecipient, reentrancyguard, pausable {
    using safemath for uint256;
    using safeerc20 for ierc20;

    

    ierc20 public rewardstoken;
    ierc20 public stakingtoken;
    uint256 public periodfinish = 0;
    uint256 public rewardrate = 0;
    uint256 public rewardsduration = 7 days;
    uint256 public lastupdatetime;
    uint256 public rewardpertokenstored;

    mapping(address => uint256) public userrewardpertokenpaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalsupply;
    mapping(address => uint256) private _balances;

    

    constructor(
        address _owner,
        address _rewardsdistribution,
        address _rewardstoken,
        address _stakingtoken
    ) public owned(_owner) {
        rewardstoken = ierc20(_rewardstoken);
        stakingtoken = ierc20(_stakingtoken);
        rewardsdistribution = _rewardsdistribution;
    }

    

    function totalsupply() external view returns (uint256) {
        return _totalsupply;
    }

    function balanceof(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lasttimerewardapplicable() public view returns (uint256) {
        return math.min(block.timestamp, periodfinish);
    }

    function rewardpertoken() public view returns (uint256) {
        if (_totalsupply == 0) {
            return rewardpertokenstored;
        }
        return
            rewardpertokenstored.add(
                lasttimerewardapplicable().sub(lastupdatetime).mul(rewardrate).mul(1e18).div(_totalsupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardpertoken().sub(userrewardpertokenpaid[account])).div(1e18).add(rewards[account]);
    }

    function getrewardforduration() external view returns (uint256) {
        return rewardrate.mul(rewardsduration);
    }

    

    function stake(uint256 amount) external nonreentrant notpaused updatereward(msg.sender) {
        require(amount > 0, );
        _totalsupply = _totalsupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingtoken.safetransferfrom(msg.sender, address(this), amount);
        emit staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonreentrant updatereward(msg.sender) {
        require(amount > 0, );
        _totalsupply = _totalsupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingtoken.safetransfer(msg.sender, amount);
        emit withdrawn(msg.sender, amount);
    }

    function getreward() public nonreentrant updatereward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardstoken.safetransfer(msg.sender, reward);
            emit rewardpaid(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getreward();
    }

    

    function notifyrewardamount(uint256 reward) external onlyrewardsdistribution updatereward(address(0)) {
        if (block.timestamp >= periodfinish) {
            rewardrate = reward.div(rewardsduration);
        } else {
            uint256 remaining = periodfinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardrate);
            rewardrate = reward.add(leftover).div(rewardsduration);
        }

        
        
        
        
        uint balance = rewardstoken.balanceof(address(this));
        require(rewardrate <= balance.div(rewardsduration), );

        lastupdatetime = block.timestamp;
        periodfinish = block.timestamp.add(rewardsduration);
        emit rewardadded(reward);
    }

    
    function recovererc20(address tokenaddress, uint256 tokenamount) external onlyowner {
        
        bool issnx = (keccak256(bytes()) == keccak256(bytes(erc20detailed(tokenaddress).symbol())));
        
        require(
            tokenaddress != address(stakingtoken) && tokenaddress != address(rewardstoken) && !issnx,
            
        );
        ierc20(tokenaddress).safetransfer(owner, tokenamount);
        emit recovered(tokenaddress, tokenamount);
    }

    function setrewardsduration(uint256 _rewardsduration) external onlyowner {
        require(block.timestamp > periodfinish,
            
        );
        rewardsduration = _rewardsduration;
        emit rewardsdurationupdated(rewardsduration);
    }

    

    modifier updatereward(address account) {
        rewardpertokenstored = rewardpertoken();
        lastupdatetime = lasttimerewardapplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userrewardpertokenpaid[account] = rewardpertokenstored;
        }
        _;
    }

    

    event rewardadded(uint256 reward);
    event staked(address indexed user, uint256 amount);
    event withdrawn(address indexed user, uint256 amount);
    event rewardpaid(address indexed user, uint256 reward);
    event rewardsdurationupdated(uint256 newduration);
    event recovered(address token, uint256 amount);
}
