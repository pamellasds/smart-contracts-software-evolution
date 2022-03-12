
pragma solidity 0.6.12;
import ;

abstract contract iconverterregistry {
    function getanchorcount() public virtual view returns (uint256);
    function getanchors() public virtual view returns (address[] memory);
    function getanchor(uint256 _index) public virtual view returns (iconverteranchor);
    function isanchor(address _value) public virtual view returns (bool);

    function getliquiditypoolcount() public virtual view returns (uint256);
    function getliquiditypools() public virtual view returns (address[] memory);
    function getliquiditypool(uint256 _index) public virtual view returns (iconverteranchor);
    function isliquiditypool(address _value) public virtual view returns (bool);

    function getconvertibletokencount() public virtual view returns (uint256);
    function getconvertibletokens() public virtual view returns (address[] memory);
    function getconvertibletoken(uint256 _index) public virtual view returns (ierc20token);
    function isconvertibletoken(address _value) public virtual view returns (bool);

    function getconvertibletokenanchorcount(ierc20token _convertibletoken) public virtual view returns (uint256);
    function getconvertibletokenanchors(ierc20token _convertibletoken) public virtual view returns (address[] memory);
    function getconvertibletokenanchor(ierc20token _convertibletoken, uint256 _index) public virtual view returns (iconverteranchor);
    function isconvertibletokenanchor(ierc20token _convertibletoken, address _value) public virtual view returns (bool);
}
