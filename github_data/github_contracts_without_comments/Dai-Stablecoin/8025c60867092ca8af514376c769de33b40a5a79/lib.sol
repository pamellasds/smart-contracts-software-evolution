












pragma solidity >=0.4.23;

contract dsnote {
    event lognote(
        bytes4   indexed  hash,
        address  indexed  user,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes             data
    ) anonymous;

    modifier note {
        _;

        bytes32 arg1;
        bytes32 arg2;

        assembly {
            arg1 := calldataload(4)
            arg2 := calldataload(36)
        }

        emit lognote(msg.sig, msg.sender, arg1, arg2, msg.data);
    }
}
