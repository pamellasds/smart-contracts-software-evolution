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
}
