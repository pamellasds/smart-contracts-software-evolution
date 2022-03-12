

pragma solidity 0.4.25;

import ;

contract tokenfallbackcaller is reentrancypreventer {
    uint constant max_gas_sub_call = 200000;
    function calltokenfallbackifneeded(address sender, address recipient, uint amount, bytes data)
        internal
        preventreentrancy
    {
        

        
        uint length;

        
        assembly {
            
            length := extcodesize(recipient)
        }

        
        if (length > 0) {
            
            uint gaslimit = gasleft() < max_gas_sub_call ? gasleft() : max_gas_sub_call;
            
            
            
            recipient.call.gas(gaslimit)(abi.encodewithsignature(, sender, amount, data));

            
        }
    }
}
