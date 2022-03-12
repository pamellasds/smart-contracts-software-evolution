pragma solidity ^0.4.18;
import ;


contract itokenconverter {
    function convertibletokencount() public view returns (uint16);
    function convertibletoken(uint16 _tokenindex) public view returns (address);
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public view returns (uint256);
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
}
