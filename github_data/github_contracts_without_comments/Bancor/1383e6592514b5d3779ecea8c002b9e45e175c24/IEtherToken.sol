
pragma solidity 0.6.12;
import ;


abstract contract iethertoken is ierc20token {
    function deposit() public virtual payable;
    function withdraw(uint256 _amount) public virtual;
    function depositto(address _to) public virtual payable;
    function withdrawto(address payable _to, uint256 _amount) public virtual;
}
