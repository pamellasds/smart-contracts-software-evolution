pragma solidity 0.4.25;


interface isynthetixescrow {
    function balanceof(address account) public view returns (uint);
    function appendvestingentry(address account, uint quantity) public;
}
