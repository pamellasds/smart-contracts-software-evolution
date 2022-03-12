pragma solidity ^0.4.10;
import ;


contract smarttokeninterface is erc20tokeninterface {
    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public returns (bool success);
    function destroy(address _from, uint256 _amount) public returns (bool success);
    function setchanger(address _changer) public returns (bool success);

    event changerupdate(address _prevchanger, address _newchanger);
}
