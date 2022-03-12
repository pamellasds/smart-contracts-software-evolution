pragma solidity ^0.4.24;

library address {
    
    function iscontract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
  }
