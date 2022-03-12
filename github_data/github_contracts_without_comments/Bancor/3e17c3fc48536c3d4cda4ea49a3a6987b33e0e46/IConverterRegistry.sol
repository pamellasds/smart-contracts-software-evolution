pragma solidity 0.4.26;

contract iconverterregistry {
    function getanchorcount() public view returns (uint256);
    function getanchors() public view returns (address[]);
    function getanchor(uint256 _index) public view returns (address);
    function isanchor(address _value) public view returns (bool);
    function getliquiditypoolcount() public view returns (uint256);
    function getliquiditypools() public view returns (address[]);
    function getliquiditypool(uint256 _index) public view returns (address);
    function isliquiditypool(address _value) public view returns (bool);
    function getconvertibletokencount() public view returns (uint256);
    function getconvertibletokens() public view returns (address[]);
    function getconvertibletoken(uint256 _index) public view returns (address);
    function isconvertibletoken(address _value) public view returns (bool);
    function getconvertibletokenanchorcount(address _convertibletoken) public view returns (uint256);
    function getconvertibletokenanchors(address _convertibletoken) public view returns (address[]);
    function getconvertibletokenanchor(address _convertibletoken, uint256 _index) public view returns (address);
    function isconvertibletokenanchor(address _convertibletoken, address _value) public view returns (bool);
}
