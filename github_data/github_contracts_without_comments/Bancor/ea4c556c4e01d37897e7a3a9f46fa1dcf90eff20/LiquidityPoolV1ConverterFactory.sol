pragma solidity 0.4.26;
import ;
import ;
import ;
import ;


contract liquiditypoolv1converterfactory is itypedconverterfactory {
    
    function convertertype() public pure returns (uint16) {
        return 1;
    }

    
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) public returns (iconverter) {
        iconverter converter = new liquiditypoolv1converter(ismarttoken(_anchor), _registry, _maxconversionfee);
        converter.transferownership(msg.sender);
        return converter;
    }
}
