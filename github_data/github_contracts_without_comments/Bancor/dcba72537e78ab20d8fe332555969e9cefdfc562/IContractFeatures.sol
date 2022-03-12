pragma solidity ^0.4.21;


contract icontractfeatures {
    function issupported(address _contract, uint256 _feature) public returns (bool);
    function enablefeatures(uint256 _features, bool _enable) public;
}
