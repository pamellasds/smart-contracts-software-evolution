pragma solidity >=0.4.24;


interface iliquidations {
    
    function isopenforliquidation(address account) external view returns (bool);

    function getliquidationdeadlineforaccount(address account) external view returns (uint);

    function isliquidationdeadlinepassed(address account) external view returns (bool);

    function liquidationdelay() external view returns (uint);

    function liquidationratio() external view returns (uint);

    function liquidationpenalty() external view returns (uint);

    function calculateamounttofixcollateral(
        uint debtbalance,
        uint collateral
    ) external view returns (uint);

    
    function flagaccountforliquidation(address account) external;

    
    function removeaccountinliquidation(address account) external;

    function checkandremoveaccountinliquidation(address account) external;
}
