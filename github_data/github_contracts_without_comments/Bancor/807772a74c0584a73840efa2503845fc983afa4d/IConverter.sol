
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;


interface iconverter is iowned {
    function convertertype() external pure returns (uint16);
    function anchor() external view returns (iconverteranchor);
    function isactive() external view returns (bool);

    function targetamountandfee(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) external view returns (uint256, uint256);
    function convert(ierc20token _sourcetoken,
                     ierc20token _targettoken,
                     uint256 _amount,
                     address _trader,
                     address payable _beneficiary) external payable returns (uint256);

    function conversionwhitelist() external view returns (iwhitelist);
    function conversionfee() external view returns (uint32);
    function maxconversionfee() external view returns (uint32);
    function reservebalance(ierc20token _reservetoken) external view returns (uint256);
    receive() external payable;

    function transferanchorownership(address _newowner) external;
    function acceptanchorownership() external;
    function setconversionfee(uint32 _conversionfee) external;
    function setconversionwhitelist(iwhitelist _whitelist) external;
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) external;
    function withdraweth(address payable _to) external;
    function addreserve(ierc20token _token, uint32 _ratio) external;

    
    function token() external view returns (iconverteranchor);
    function transfertokenownership(address _newowner) external;
    function accepttokenownership() external;
    function connectors(ierc20token _address) external view returns (uint256, uint32, bool, bool, bool);
    function getconnectorbalance(ierc20token _connectortoken) external view returns (uint256);
    function connectortokens(uint256 _index) external view returns (ierc20token);
    function connectortokencount() external view returns (uint16);
}
