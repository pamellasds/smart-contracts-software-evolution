pragma solidity ^0.4.24;
import ;
import ;


contract ibancorconverter {
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public view returns (uint256, uint256);
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
    function conversionwhitelist() public view returns (iwhitelist) {}
    function conversionfee() public view returns (uint32) {}
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool) { _address; }
    function getconnectorbalance(ierc20token _connectortoken) public view returns (uint256);
    function claimtokens(address _from, uint256 _amount) public;
    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
}
