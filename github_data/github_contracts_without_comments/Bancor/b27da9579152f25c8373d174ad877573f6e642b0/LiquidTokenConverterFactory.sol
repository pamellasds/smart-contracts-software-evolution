
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;


contract liquidtokenconverterfactory is itypedconverterfactory {
    
    function convertertype() external pure override returns (uint16) {
        return 0;
    }

    
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) external override returns (iconverter) {
        iconverter converter = new liquidtokenconverter(idstoken(address(_anchor)), _registry, _maxconversionfee);
        converter.transferownership(msg.sender);
        return converter;
    }
}
