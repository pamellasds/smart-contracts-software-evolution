pragma solidity ^0.5.16;


interface ihasbalance {
    
    function balanceof(address account) external view returns (uint);
}
