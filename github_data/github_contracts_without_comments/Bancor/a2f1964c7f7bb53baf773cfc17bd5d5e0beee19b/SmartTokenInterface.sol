pragma solidity ^0.4.10;
import ;


contract smarttokeninterface is erc20tokeninterface {
    
    function changer() public constant returns (address changer) {}

    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
    function setchanger(address _changer) public;
}
