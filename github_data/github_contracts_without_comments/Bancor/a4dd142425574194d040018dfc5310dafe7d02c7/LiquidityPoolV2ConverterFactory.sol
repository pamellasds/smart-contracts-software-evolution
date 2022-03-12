pragma solidity 0.4.26;
import ;
import ;
import ;


contract liquiditypoolv2converterfactory is itypedconverterfactory {
    
    function convertertype() public pure returns (uint16) {
        return 2;
    }

    
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) public returns (iconverter) {
        converterbase converter = new liquiditypoolv2converter(ipooltokenscontainer(_anchor), _registry, _maxconversionfee);
        converter.transferownership(msg.sender);
        return converter;
    }
}
