
pragma solidity 0.6.12;
import ;
import ;

interface iconverterregistry {
    function getanchorcount() external view returns (uint256);
    function getanchors() external view returns (address[] memory);
    function getanchor(uint256 _index) external view returns (iconverteranchor);
    function isanchor(address _value) external view returns (bool);

    function getliquiditypoolcount() external view returns (uint256);
    function getliquiditypools() external view returns (address[] memory);
    function getliquiditypool(uint256 _index) external view returns (iconverteranchor);
    function isliquiditypool(address _value) external view returns (bool);

    function getconvertibletokencount() external view returns (uint256);
    function getconvertibletokens() external view returns (address[] memory);
    function getconvertibletoken(uint256 _index) external view returns (ierc20token);
    function isconvertibletoken(address _value) external view returns (bool);

    function getconvertibletokenanchorcount(ierc20token _convertibletoken) external view returns (uint256);
    function getconvertibletokenanchors(ierc20token _convertibletoken) external view returns (address[] memory);
    function getconvertibletokenanchor(ierc20token _convertibletoken, uint256 _index) external view returns (iconverteranchor);
    function isconvertibletokenanchor(ierc20token _convertibletoken, address _value) external view returns (bool);
}
