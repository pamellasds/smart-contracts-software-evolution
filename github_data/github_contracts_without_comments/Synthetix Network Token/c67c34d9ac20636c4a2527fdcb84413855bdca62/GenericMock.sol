


pragma solidity 0.4.25;


contract genericmock {
    mapping(bytes4 => bytes) mockconfig;

    function() public {
        bytes memory ret = mockconfig[msg.sig];
        assembly {
            return(add(ret, 0x20), mload(ret))
        }
    }

    function mockreturns(bytes4 key, bytes value) public {
        mockconfig[key] = value;
    }
}
