pragma solidity ^0.4.11;


contract iowned {
    
    function owner() public constant returns (address) {}

    function transferownership(address _newowner) public;
    function acceptownership() public;
}
