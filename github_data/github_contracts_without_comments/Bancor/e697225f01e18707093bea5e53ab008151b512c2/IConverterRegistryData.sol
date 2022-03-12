
pragma solidity 0.6.12;
import ;
import ;

interface iconverterregistrydata {
    function addsmarttoken(iconverteranchor _anchor) external;
    function removesmarttoken(iconverteranchor _anchor) external;

    function addliquiditypool(iconverteranchor _liquiditypoolanchor) external;
    function removeliquiditypool(iconverteranchor _liquiditypoolanchor) external;

    function addconvertibletoken(ierc20token _convertibletoken, iconverteranchor _anchor) external;
    function removeconvertibletoken(ierc20token _convertibletoken, iconverteranchor _anchor) external;

    function getsmarttokencount() external view returns (uint256);
    function getsmarttokens() external view returns (address[] memory);
    function getsmarttoken(uint256 _index) external view returns (iconverteranchor);
    function issmarttoken(address _value) external view returns (bool);

    function getliquiditypoolcount() external view returns (uint256);
    function getliquiditypools() external view returns (address[] memory);
    function getliquiditypool(uint256 _index) external view returns (iconverteranchor);
    function isliquiditypool(address _value) external view returns (bool);

    function getconvertibletokencount() external view returns (uint256);
    function getconvertibletokens() external view returns (address[] memory);
    function getconvertibletoken(uint256 _index) external view returns (ierc20token);
    function isconvertibletoken(address _value) external view returns (bool);

    function getconvertibletokensmarttokencount(ierc20token _convertibletoken) external view returns (uint256);
    function getconvertibletokensmarttokens(ierc20token _convertibletoken) external view returns (address[] memory);
    function getconvertibletokensmarttoken(ierc20token _convertibletoken, uint256 _index) external view returns (iconverteranchor);
    function isconvertibletokensmarttoken(ierc20token _convertibletoken, address _value) external view returns (bool);
}
