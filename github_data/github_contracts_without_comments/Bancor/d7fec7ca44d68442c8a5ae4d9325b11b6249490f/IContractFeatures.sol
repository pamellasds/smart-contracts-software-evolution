pragma solidity ^0.4.24;


contract icontractfeatures {
    function issupported(address _contract, uint256 _features) public view returns (bool);
    function enablefeatures(uint256 _features, bool _enable) public;
}
