pragma solidity ^0.4.10;
import ;
import ;


contract ismarttoken is ierc20token {
    
    function changer() public constant returns (itokenchanger changer) {}

    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
    function setchanger(itokenchanger _changer) public;
}
