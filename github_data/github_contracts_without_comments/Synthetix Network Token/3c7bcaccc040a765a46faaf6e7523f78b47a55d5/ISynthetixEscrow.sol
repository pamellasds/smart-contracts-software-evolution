pragma solidity ^0.5.16;



interface isynthetixescrow {
    function balanceof(address account) external view returns (uint);

    function appendvestingentry(address account, uint quantity) external;
}
