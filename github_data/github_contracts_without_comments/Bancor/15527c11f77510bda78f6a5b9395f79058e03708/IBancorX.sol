
pragma solidity 0.6.12;
import ;

interface ibancorx {
    function token() external view returns (ierc20token);
    function xtransfer(bytes32 _toblockchain, bytes32 _to, uint256 _amount, uint256 _id) external;
    function getxtransferamount(uint256 _xtransferid, address _for) external view returns (uint256);
}
