pragma solidity ^0.4.11;
import ;


contract ibancorquickconverter {
    function convert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public payable returns (uint256);
    function convertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for) public payable returns (uint256);
}
