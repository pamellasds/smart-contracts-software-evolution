pragma solidity ^0.4.24;
import ;


contract inonstandardsmarttoken is inonstandarderc20 {
    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}
