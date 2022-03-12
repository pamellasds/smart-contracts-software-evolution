
pragma solidity 0.4.25;

import ;
import ;

contract synthetixairdropper is owned {
    

    
    constructor (address _owner)
        owned(_owner)
        public
    {}

    
    function multisend(address _tokenaddress, address[] _destinations, uint256[] _values)
        external
        onlyowner
    {
        
        require(_destinations.length == _values.length, );

        
        uint256 i = 0;
        while (i < _destinations.length) {
            isynthetix(_tokenaddress).transfer(_destinations[i], _values[i]);
            i += 1;
        }
    }

    
    function ()
        external
        payable
    {
        owner.transfer(msg.value);
    }
}
