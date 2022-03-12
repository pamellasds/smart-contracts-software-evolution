pragma solidity ^0.4.10;


contract itokenchanger {
    function changeabletokencount() public constant returns (uint16 count);
    function changeabletoken(uint16 _tokenindex) public constant returns (address tokenaddress);
    function getreturn(address _fromtoken, address _totoken, uint256 _amount) public constant returns (uint256 amount);
    function change(address _fromtoken, address _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256 amount);
}
