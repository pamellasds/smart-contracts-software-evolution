pragma solidity ^0.4.21;
import ;
import ;


contract ibancorconverter is itokenconverter {
    uint256 public constant feature_conversion_whitelist = 1 << 0;

    function conversionwhitelist() public view returns (iwhitelist) {}
}
