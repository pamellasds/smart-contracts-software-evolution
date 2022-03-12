pragma solidity ^0.4.11;
import ;
import ;


contract ismarttoken is itokenholder, ierc20token {
    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}
