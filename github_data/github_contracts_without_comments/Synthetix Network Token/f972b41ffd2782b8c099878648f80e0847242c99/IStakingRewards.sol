pragma solidity >=0.4.24;


interface istakingrewards {
    
    function lasttimerewardapplicable() external view returns (uint256);

    function rewardpertoken() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getrewardforduration() external view returns (uint256);

    function totalsupply() external view returns (uint256);

    function balanceof(address account) external view returns (uint256);

    

    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function getreward() external;

    function exit() external;
}
