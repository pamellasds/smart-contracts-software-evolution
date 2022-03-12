pragma solidity ^0.4.11;
import ;


contract itokenconverter {
    function convertibletokencount() public constant returns (uint16);
    function convertibletoken(uint16 _tokenindex) public constant returns (address);
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public constant returns (uint256);
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
}
