pragma solidity 0.4.26;
import ;

contract tokenhandler {
    bytes4 private constant approve_func_selector = bytes4(keccak256());
    bytes4 private constant transfer_func_selector = bytes4(keccak256());
    bytes4 private constant transfer_from_func_selector = bytes4(keccak256());

    
    function safeapprove(ierc20token _token, address _spender, uint256 _value) public {
       execute(_token, abi.encodewithselector(approve_func_selector, _spender, _value));
    }

    
    function safetransfer(ierc20token _token, address _to, uint256 _value) public {
       execute(_token, abi.encodewithselector(transfer_func_selector, _to, _value));
    }

    
    function safetransferfrom(ierc20token _token, address _from, address _to, uint256 _value) public {
       execute(_token, abi.encodewithselector(transfer_from_func_selector, _from, _to, _value));
    }

    
    function execute(ierc20token _token, bytes memory _data) private {
        uint256[1] memory ret = [uint256(1)];

        assembly {
            let success := call(
                gas,            
                _token,         
                0,              
                add(_data, 32), 
                mload(_data),   
                ret,            
                32              
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        require(ret[0] != 0, );
    }
}
