












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
        assembly {
            
            
            let mark := msize                      
            mstore(0x40, add(mark, 288))           
            mstore(mark, 0x20)                     
            mstore(add(mark, 0x20), 224)           
            calldatacopy(add(mark, 0x40), 0, 224)  
            log4(mark, 288,                        
                 shr(224, calldataload(0)),        
                 caller,                           
                 calldataload(4),                  
                 calldataload(36)                  
                )
        }
    }
}
