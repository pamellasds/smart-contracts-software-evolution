pragma solidity ^0.4.24;
import ;
import ;
import ;


contract ibancorconverterfactory {
    function createconverter(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee,
        ierc20token _connectortoken,
        uint32 _connectorweight
    )
    public returns (address);
}
