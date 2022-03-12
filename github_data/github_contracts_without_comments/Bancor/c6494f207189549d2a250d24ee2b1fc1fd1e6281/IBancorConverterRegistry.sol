pragma solidity 0.4.26;
import ;

interface ibancorconverterregistry {
    function addconverter(ibancorconverter _converter) external;
    function removeconverter(ibancorconverter _converter) external;
    function getsmarttokencount() external view returns (uint);
    function getsmarttokens() external view returns (address[]);
    function getsmarttoken(uint _index) external view returns (address);
    function issmarttoken(address _value) external view returns (bool);
    function getliquiditypoolcount() external view returns (uint);
    function getliquiditypools() external view returns (address[]);
    function getliquiditypool(uint _index) external view returns (address);
    function isliquiditypool(address _value) external view returns (bool);
    function getconvertibletokencount() external view returns (uint);
    function getconvertibletokens() external view returns (address[]);
    function getconvertibletoken(uint _index) external view returns (address);
    function isconvertibletoken(address _value) external view returns (bool);
    function getconvertibletokensmarttokencount(address _convertibletoken) external view returns (uint);
    function getconvertibletokensmarttokens(address _convertibletoken) external view returns (address[]);
    function getconvertibletokensmarttoken(address _convertibletoken, uint _index) external view returns (address);
    function isconvertibletokensmarttoken(address _convertibletoken, address _value) external view returns (bool);
}
