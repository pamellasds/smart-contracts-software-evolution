pragma solidity ^0.4.18;
import ;
import ;


contract iethertoken is itokenholder, ierc20token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
    function withdrawto(address _to, uint256 _amount) public;
}
