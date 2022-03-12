pragma solidity 0.4.26;

interface iconverterregistrydata {
    function addsmarttoken(address _smarttoken) external;
    function removesmarttoken(address _smarttoken) external;
    function addliquiditypool(address _liquiditypool) external;
    function removeliquiditypool(address _liquiditypool) external;
    function addconvertibletoken(address _convertibletoken, address _smarttoken) external;
    function removeconvertibletoken(address _convertibletoken, address _smarttoken) external;
    function getsmarttokencount() external view returns (uint256);
    function getsmarttokens() external view returns (address[]);
    function getsmarttoken(uint256 _index) external view returns (address);
    function issmarttoken(address _value) external view returns (bool);
    function getliquiditypoolcount() external view returns (uint256);
    function getliquiditypools() external view returns (address[]);
    function getliquiditypool(uint256 _index) external view returns (address);
    function isliquiditypool(address _value) external view returns (bool);
    function getconvertibletokencount() external view returns (uint256);
    function getconvertibletokens() external view returns (address[]);
    function getconvertibletoken(uint256 _index) external view returns (address);
    function isconvertibletoken(address _value) external view returns (bool);
    function getconvertibletokensmarttokencount(address _convertibletoken) external view returns (uint256);
    function getconvertibletokensmarttokens(address _convertibletoken) external view returns (address[]);
    function getconvertibletokensmarttoken(address _convertibletoken, uint256 _index) external view returns (address);
    function isconvertibletokensmarttoken(address _convertibletoken, address _value) external view returns (bool);
}
