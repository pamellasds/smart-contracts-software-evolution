pragma solidity ^0.4.22;

import ;





contract owned {
    address owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

}


contract target is owned{
    uint256 constant targetbasegasprice = 1e14;
    bytes32 constant keybasegasprice = bytes32();

    params params = builtin.getparams();

    
    function updatebasegasprice() public {
        params.set(keybasegasprice, targetbasegasprice);
    }
}

contract voting is owned{
    target target;
    bytes32 proposalid;
    executor executor = builtin.getexecutor();
    uint64 starttime;

    
    function propose() public onlyowner {
        proposalid = executor.propose(address(target), abi.encodepacked(keccak256()));
        starttime = uint64(now);
    }

    
    function isexpired() public view returns(bool){
        return starttime + uint64(1 weeks) > uint64(now);
    }

    
    function execute() public onlyowner {
        executor.execute(proposalid);
    }

    
    function approve() public {
        executor.approve(proposalid);
    }
}
