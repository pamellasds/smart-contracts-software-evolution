
pragma solidity 0.6.12;
import ;


contract testtokenhandler is tokenhandler {
    function testsafeapprove(ierc20token _token, address _spender, uint256 _value) public {
        safeapprove(_token, _spender, _value);
    }

    function testsafetransfer(ierc20token _token, address _to, uint256 _value) public {
        safetransfer(_token, _to, _value);
    }

    function testsafetransferfrom(ierc20token _token, address _from, address _to, uint256 _value) public {
        safetransferfrom(_token, _from, _to, _value);
    }
}
