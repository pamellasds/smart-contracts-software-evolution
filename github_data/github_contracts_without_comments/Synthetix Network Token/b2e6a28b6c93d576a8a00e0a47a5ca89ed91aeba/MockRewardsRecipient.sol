pragma solidity 0.4.25;

import ;
import ;


contract mockrewardsrecipient is rewardsdistributionrecipient {
    uint256 public rewardsavailable;

    constructor(address _owner) public owned(_owner) {}

    function notifyrewardamount(uint256 reward) external onlyrewardsdistribution {
        rewardsavailable = rewardsavailable + reward;
        emit rewardadded(reward);
    }

    event rewardadded(uint256 amount);
}
