pragma solidity ^0.4.24;

import ;
import ;

contract bancorxenabledconverter is bancorconverter, ibancorxenabledconverter {
    
    
    constructor(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee,
        ierc20token _connectortoken,
        uint32 _connectorweight
    ) bancorconverter(
        _token,
        _registry,
        _maxconversionfee,
        _connectortoken,
        _connectorweight
    ) public {}

    
    function claimtokens(address _from, uint256 _amount) public {
        address bancorx = registry.addressof(contractids.bancor_x);

        
        require(msg.sender == bancorx);

        
        token.destroy(_from, _amount);
        token.issue(bancorx, _amount);
    }
}
