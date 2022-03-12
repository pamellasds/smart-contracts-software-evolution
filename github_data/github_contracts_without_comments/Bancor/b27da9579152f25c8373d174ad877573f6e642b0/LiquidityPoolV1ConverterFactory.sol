
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;


contract liquiditypoolv1converterfactory is itypedconverterfactory {
    
    function convertertype() external pure override returns (uint16) {
        return 1;
    }

    
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee)
        external
        virtual
        override
        returns (iconverter)
    {
        iconverter converter = new liquiditypoolv1converter(idstoken(address(_anchor)), _registry, _maxconversionfee);
        converter.transferownership(msg.sender);
        return converter;
    }
}
