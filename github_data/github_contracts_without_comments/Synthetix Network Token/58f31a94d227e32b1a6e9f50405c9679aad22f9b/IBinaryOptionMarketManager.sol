pragma solidity >=0.4.24;

import ;

interface ibinaryoptionmarketmanager {
    

    function fees() external view returns (uint poolfee, uint creatorfee, uint refundfee);
    function durations() external view returns (uint maxoraclepriceage, uint expiryduration, uint maxtimetomaturity);
    function creatorlimits() external view returns (uint capitalrequirement, uint skewlimit);

    function marketcreationenabled() external view returns (bool);
    function totaldeposited() external view returns (uint);

    function numactivemarkets() external view returns (uint);
    function activemarkets(uint index, uint pagesize) external view returns (address[] memory);
    function nummaturedmarkets() external view returns (uint);
    function maturedmarkets(uint index, uint pagesize) external view returns (address[] memory);

    

    function createmarket(
        bytes32 oraclekey, uint strikeprice,
        uint[2] calldata times, 
        uint[2] calldata bids 
    ) external returns (ibinaryoptionmarket);
    function resolvemarket(address market) external;
    function expiremarkets(address[] calldata market) external;
}
