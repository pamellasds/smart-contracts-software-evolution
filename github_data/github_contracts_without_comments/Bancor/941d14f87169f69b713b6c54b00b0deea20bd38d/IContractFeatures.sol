pragma solidity ^0.4.21;


contract icontractfeatures {
    function issupported(address _contract, uint256 _feature) public returns (bool);
    function enablefeature(uint256 _feature, bool _enable) public;
}
