pragma solidity 0.4.26;
import ;
import ;


contract ibancorconverter {
    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) public view returns (uint256, uint256);
    function convert2(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn, address _affiliateaccount, uint256 _affiliatefee) public returns (uint256);
    function quickconvert2(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _affiliateaccount, uint256 _affiliatefee) public payable returns (uint256);
    function conversionwhitelist() public view returns (iwhitelist) {this;}
    function conversionfee() public view returns (uint32) {this;}
    function reserves(address _address) public view returns (uint256, uint32, bool, bool, bool) {_address; this;}
    function getreservebalance(ierc20token _reservetoken) public view returns (uint256);
    function reservetokens(uint256 _index) public view returns (ierc20token) {_index; this;}

    
    function change(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
    function convert(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256);
    function quickconvert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public payable returns (uint256);
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);
    function getconnectorbalance(ierc20token _connectortoken) public view returns (uint256);
    function connectortokens(uint256 _index) public view returns (ierc20token);
    function connectortokencount() public view returns (uint16);
}
