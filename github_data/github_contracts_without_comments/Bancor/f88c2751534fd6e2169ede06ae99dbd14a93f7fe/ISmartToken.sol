
pragma solidity 0.6.12;
import ;
import ;
import ;


abstract contract ismarttoken is iconverteranchor, ierc20token {
    function disabletransfers(bool _disable) public virtual;
    function issue(address _to, uint256 _amount) public virtual;
    function destroy(address _from, uint256 _amount) public virtual;
}
