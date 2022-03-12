
pragma solidity 0.6.12;
import ;


interface iethertoken is ierc20token {
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
    function depositto(address _to) external payable;
    function withdrawto(address payable _to, uint256 _amount) external;
}
