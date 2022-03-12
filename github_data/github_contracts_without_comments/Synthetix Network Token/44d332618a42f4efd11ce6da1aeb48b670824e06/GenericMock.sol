

pragma solidity ^0.5.16;


contract genericmock {
    mapping(bytes4 => bytes) mockconfig;

    function() external {
        bytes memory ret = mockconfig[msg.sig];
        assembly {
            return(add(ret, 0x20), mload(ret))
        }
    }

    function mockreturns(bytes4 key, bytes calldata value) external {
        mockconfig[key] = value;
    }
}
