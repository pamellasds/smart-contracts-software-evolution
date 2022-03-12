pragma solidity ^0.4.24;



library addressutils {

    
    function iscontract(address addr) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}
