
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;


abstract contract iconverter is iowned {
    function convertertype() public virtual pure returns (uint16);
    function anchor() external virtual view returns (iconverteranchor);
    function isactive() public virtual view returns (bool);

    function targetamountandfee(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) public virtual view returns (uint256, uint256);
    function convert(ierc20token _sourcetoken,
                     ierc20token _targettoken,
                     uint256 _amount,
                     address _trader,
                     address payable _beneficiary) public virtual payable returns (uint256);

    function conversionwhitelist() external virtual view returns (iwhitelist);
    function conversionfee() external virtual view returns (uint32);
    function maxconversionfee() external virtual view returns (uint32);
    function reservebalance(ierc20token _reservetoken) public virtual view returns (uint256);
    receive() external virtual payable;

    function transferanchorownership(address _newowner) public virtual;
    function acceptanchorownership() public virtual;
    function setconversionfee(uint32 _conversionfee) public virtual;
    function setconversionwhitelist(iwhitelist _whitelist) public virtual;
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public virtual;
    function withdraweth(address payable _to) public virtual;
    function addreserve(ierc20token _token, uint32 _ratio) public virtual;

    
    function token() public virtual view returns (iconverteranchor);
    function transfertokenownership(address _newowner) public virtual;
    function accepttokenownership() public virtual;
    function connectors(ierc20token _address) public virtual view returns (uint256, uint32, bool, bool, bool);
    function getconnectorbalance(ierc20token _connectortoken) public virtual view returns (uint256);
    function connectortokens(uint256 _index) public virtual view returns (ierc20token);
    function connectortokencount() public virtual view returns (uint16);
}
