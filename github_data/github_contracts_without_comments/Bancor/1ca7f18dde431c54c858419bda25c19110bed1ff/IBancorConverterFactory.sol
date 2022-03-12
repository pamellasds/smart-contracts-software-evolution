pragma solidity 0.4.26;
import ;
import ;
import ;


contract ibancorconverterfactory {
    function createconverter(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee,
        ierc20token _reservetoken,
        uint32 _reserveratio
    )
    public returns (address);
}
