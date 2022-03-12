

pragma solidity 0.4.24;

import ;
import ;

contract nominairdropper is owned {
    

    
    constructor (address _owner) 
        owned(_owner)
    {}

    
    function multisend(address tokenaddress, address[] destinations, uint256[] values)
        external
        onlyowner
    {
        
        require(destinations.length == values.length, );

        
        uint256 i = 0;
        
        while (i < destinations.length) {
            nomin(tokenaddress).transfersenderpaysfee(destinations[i], values[i]);
            i += 1;
        }
    }
}