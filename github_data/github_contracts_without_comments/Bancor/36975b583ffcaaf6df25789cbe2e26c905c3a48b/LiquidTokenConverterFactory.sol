pragma solidity 0.4.26;
import ;
import ;
import ;
import ;


contract liquidtokenconverterfactory is itypedconverterfactory {
    
    function convertertype() public pure returns (uint16) {
        return 0;
    }

    
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) public returns (iconverter) {
        iconverter converter = new liquidtokenconverter(ismarttoken(_anchor), _registry, _maxconversionfee);
        converter.transferownership(msg.sender);
        return converter;
    }
}
