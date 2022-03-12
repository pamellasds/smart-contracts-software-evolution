pragma solidity ^0.4.11;
import ;
import ;
import ;


contract ismarttoken is iowned, ierc20token {
    
    function changer() public constant returns (itokenchanger changer) { changer; }

    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
    function setchanger(itokenchanger _changer) public;
}
