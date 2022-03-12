pragma solidity 0.4.26;
import ;
import ;
import ;
import ;


contract iconverter is iowned {
    function convertertype() public pure returns (uint16);
    function anchor() public view returns (iconverteranchor) {this;}
    function isactive() public view returns (bool);

    function targetamountandfee(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) public view returns (uint256, uint256);
    function convert(ierc20token _sourcetoken,
                     ierc20token _targettoken,
                     uint256 _amount,
                     address _trader,
                     address _beneficiary) public payable returns (uint256);

    function conversionwhitelist() public view returns (iwhitelist) {this;}
    function conversionfee() public view returns (uint32) {this;}
    function maxconversionfee() public view returns (uint32) {this;}
    function reservebalance(ierc20token _reservetoken) public view returns (uint256);
    function() external payable;

    function transferanchorownership(address _newowner) public;
    function acceptanchorownership() public;
    function setconversionfee(uint32 _conversionfee) public;
    function setconversionwhitelist(iwhitelist _whitelist) public;
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public;
    function withdraweth(address _to) public;
    function addreserve(ierc20token _token, uint32 _ratio) public;

    
    function token() public view returns (iconverteranchor);
    function transfertokenownership(address _newowner) public;
    function accepttokenownership() public;
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);
    function getconnectorbalance(ierc20token _connectortoken) public view returns (uint256);
    function connectortokens(uint256 _index) public view returns (ierc20token);
    function connectortokencount() public view returns (uint16);
}
