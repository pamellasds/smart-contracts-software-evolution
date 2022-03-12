pragma solidity ^0.4.24;

contract ibancorx {
    function xtransfer(bytes32 _toblockchain, bytes32 _to, uint256 _amount, uint256 _id) public;
    function getxtransferamount(uint256 _xtransferid, address _for) public view returns (uint256);
}
