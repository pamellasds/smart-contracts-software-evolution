pragma solidity 0.4.26;
import ;
import ;
import ;


contract ismarttoken is iconverteranchor, ierc20token {
    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}
