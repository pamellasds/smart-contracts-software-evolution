

pragma solidity >=0.4.10;

contract itoken {
    function transfer(address _to, uint _value) returns (bool);
    function balanceof(address owner) returns(uint);
}