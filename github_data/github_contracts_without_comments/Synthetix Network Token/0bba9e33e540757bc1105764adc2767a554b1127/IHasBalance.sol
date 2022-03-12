pragma solidity >=0.4.24;


interface ihasbalance {
    
    function balanceof(address account) external view returns (uint);
}
