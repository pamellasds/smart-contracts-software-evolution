pragma solidity ^0.4.10;
import ;


contract iethertoken is ierc20token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
}
