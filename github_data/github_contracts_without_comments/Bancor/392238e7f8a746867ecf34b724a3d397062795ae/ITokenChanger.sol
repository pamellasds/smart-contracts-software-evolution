pragma solidity ^0.4.11;
import ;


contract itokenchanger {
    function changeabletokencount() public constant returns (uint16);
    function changeabletoken(uint16 _tokenindex) public constant returns (address);
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public constant returns (uint256);
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
}
