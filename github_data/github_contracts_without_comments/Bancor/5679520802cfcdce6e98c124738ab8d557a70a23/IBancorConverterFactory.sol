pragma solidity ^0.4.21;
import ;
import ;
import ;
import ;


contract ibancorconverterfactory {
    function createconverter(
        ismarttoken _token,
        icontractregistry _registry,
        ibancorconverterextensions _extensions,
        uint32 _maxconversionfee,
        ierc20token _connectortoken,
        uint32 _connectorweight
    )
    public returns (address);
}
