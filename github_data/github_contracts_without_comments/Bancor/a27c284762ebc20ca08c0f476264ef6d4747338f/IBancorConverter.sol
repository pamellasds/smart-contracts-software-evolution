pragma solidity ^0.4.21;
import ;
import ;


contract ibancorconverter {
    uint256 public constant feature_conversion_whitelist = 1 << 0;

    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public view returns (uint256);
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
    function conversionwhitelist() public view returns (iwhitelist) {}
    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
}
