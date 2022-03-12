pragma solidity 0.4.26;
import ;


contract ibancornetwork {
    function convert2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _affiliateaccount,
        uint256 _affiliatefee
    ) public payable returns (uint256);

    function claimandconvert2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _affiliateaccount,
        uint256 _affiliatefee
    ) public returns (uint256);

    function convertfor2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        address _affiliateaccount,
        uint256 _affiliatefee
    ) public payable returns (uint256);

    function claimandconvertfor2(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        address _affiliateaccount,
        uint256 _affiliatefee
    ) public returns (uint256);

    
    function convert(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn
    ) public payable returns (uint256);

    
    function claimandconvert(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn
    ) public returns (uint256);

    
    function convertfor(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for
    ) public payable returns (uint256);

    
    function claimandconvertfor(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for
    ) public returns (uint256);

    
    function convertforprioritized4(
        ierc20token[] _path,
        uint256 _amount,
        uint256 _minreturn,
        address _for,
        uint256[] memory _signature,
        address _affiliateaccount,
        uint256 _affiliatefee
    ) public payable returns (uint256);

    
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
