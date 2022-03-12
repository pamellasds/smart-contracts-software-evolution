pragma solidity ^0.4.18;
import ;
import ;


contract ismarttoken is iowned, ierc20token {
    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}
