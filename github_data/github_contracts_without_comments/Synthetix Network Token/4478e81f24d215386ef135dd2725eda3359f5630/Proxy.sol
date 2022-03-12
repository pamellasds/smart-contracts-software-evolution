pragma solidity ^0.5.16;


import ;


import ;



contract proxy is owned {
    proxyable public target;

    constructor(address _owner) public owned(_owner) {}

    function settarget(proxyable _target) external onlyowner {
        target = _target;
        emit targetupdated(_target);
    }

    function _emit(
        bytes calldata calldata,
        uint numtopics,
        bytes32 topic1,
        bytes32 topic2,
        bytes32 topic3,
        bytes32 topic4
    ) external onlytarget {
        uint size = calldata.length;
        bytes memory _calldata = calldata;

        assembly {
            
            switch numtopics
                case 0 {
                    log0(add(_calldata, 32), size)
                }
                case 1 {
                    log1(add(_calldata, 32), size, topic1)
                }
                case 2 {
                    log2(add(_calldata, 32), size, topic1, topic2)
                }
                case 3 {
                    log3(add(_calldata, 32), size, topic1, topic2, topic3)
                }
                case 4 {
                    log4(add(_calldata, 32), size, topic1, topic2, topic3, topic4)
                }
        }
    }

    function() external payable {        
        
        target.setmessagesender(msg.sender);

        assembly {
            let free_ptr := mload(0x40)
            calldatacopy(free_ptr, 0, calldatasize)

            
            let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
            returndatacopy(free_ptr, 0, returndatasize)

            if iszero(result) {
                revert(free_ptr, returndatasize)
            }
            return(free_ptr, returndatasize)
        }
    }

    modifier onlytarget {
        require(proxyable(msg.sender) == target, );
        _;
    }

    event targetupdated(proxyable newtarget);
}
