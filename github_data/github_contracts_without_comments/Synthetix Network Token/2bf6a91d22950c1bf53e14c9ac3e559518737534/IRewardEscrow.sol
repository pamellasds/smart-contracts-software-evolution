pragma solidity >=0.4.24;


interface irewardescrow {
    
    function balanceof(address account) external view returns (uint);

    function numvestingentries(address account) external view returns (uint);

    
    function appendvestingentry(address account, uint quantity) external;

    function vest() external;
}
