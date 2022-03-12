
pragma solidity 0.6.12;
import ;
import ;


interface itokenholder is iowned {
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) external;
}
