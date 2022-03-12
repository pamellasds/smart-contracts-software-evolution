
pragma solidity 0.6.12;
import ;

contract tokenhandler {
    bytes4 private constant approve_func_selector = bytes4(keccak256());
    bytes4 private constant transfer_func_selector = bytes4(keccak256());
    bytes4 private constant transfer_from_func_selector = bytes4(keccak256());

    
    function safeapprove(ierc20token _token, address _spender, uint256 _value) internal {
        (bool success, bytes memory data) = address(_token).call(abi.encodewithselector(approve_func_selector, _spender, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), );
    }

    
    function safetransfer(ierc20token _token, address _to, uint256 _value) internal {
       (bool success, bytes memory data) = address(_token).call(abi.encodewithselector(transfer_func_selector, _to, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), );
    }

    
    function safetransferfrom(ierc20token _token, address _from, address _to, uint256 _value) internal {
       (bool success, bytes memory data) = address(_token).call(abi.encodewithselector(transfer_from_func_selector, _from, _to, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), );
    }
}
