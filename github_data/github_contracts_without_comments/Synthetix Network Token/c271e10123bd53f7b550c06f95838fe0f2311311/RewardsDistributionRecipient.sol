pragma solidity 0.4.25;

import ;



contract rewardsdistributionrecipient is owned {
    address rewardsdistribution;

    function notifyrewardamount(uint256 reward) external;

    modifier onlyrewardsdistribution() {
        require(msg.sender == rewardsdistribution, );
        _;
    }

    function setrewardsdistribution(address _rewardsdistribution) external onlyowner {
        rewardsdistribution = _rewardsdistribution;
    }
}
