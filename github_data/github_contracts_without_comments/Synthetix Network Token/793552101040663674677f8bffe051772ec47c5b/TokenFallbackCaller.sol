

pragma solidity 0.4.25;

import ;

contract tokenfallbackcaller is reentrancypreventer {
    function calltokenfallbackifneeded(address sender, address recipient, uint amount, bytes data)
        internal
        preventreentrancy
    {
        

        
        uint length;

        
        assembly {
            
            length := extcodesize(recipient)
        }

        
        if (length > 0) {
            
            

            
            recipient.call(abi.encodewithsignature(, sender, amount, data));

            
        }
    }
}
