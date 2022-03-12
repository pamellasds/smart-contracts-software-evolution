pragma solidity 0.4.26;
import ;


contract iethertoken is ierc20token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
    function depositto(address _to) public payable;
    function withdrawto(address _to, uint256 _amount) public;
}
