
pragma solidity 0.6.12;
import ;
import ;
import ;


contract liquiditypoolv2converterfactory is itypedconverterfactory {
    
    function convertertype() external pure override returns (uint16) {
        return 2;
    }

    
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) external override returns (iconverter) {
        converterbase converter = new liquiditypoolv2converter(ipooltokenscontainer(address(_anchor)), _registry, _maxconversionfee);
        converter.transferownership(msg.sender);
        return converter;
    }
}
