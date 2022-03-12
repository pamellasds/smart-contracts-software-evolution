
pragma solidity>=0.4.10;


contract token {
    function balanceof(address addr) returns(uint);
    function transfer(address to, uint amount) returns(bool);
}