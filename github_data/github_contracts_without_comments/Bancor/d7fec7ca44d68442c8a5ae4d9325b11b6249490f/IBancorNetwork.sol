pragma solidity ^0.4.24;
import ;


contract ibancornetwork {
    function convert(ierc20token[] _path, uint256 _amount, uint256 _minreturn) public payable returns (uint256);
    function convertfor(ierc20token[] _path, uint256 _amount, uint256 _minreturn, address _for) public payable returns (uint256);
    
    function convertforprioritized3(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        uint256 _customval,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);
    
    
    function convertforprioritized2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);

    
    function convertforprioritized(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        uint256 _block,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);
}