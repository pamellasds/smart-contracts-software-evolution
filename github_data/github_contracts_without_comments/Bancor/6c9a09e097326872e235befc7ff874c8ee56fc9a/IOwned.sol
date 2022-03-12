pragma solidity ^0.4.23;


contract iowned {
    
    function owner() public view returns (address) {}

    function transferownership(address _newowner) public;
    function acceptownership() public;
}
