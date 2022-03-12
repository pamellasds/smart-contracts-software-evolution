
pragma solidity 0.6.12;
import ;
import ;
import ;


interface itypedconverterfactory {
    function convertertype() external pure returns (uint16);
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) external returns (iconverter);
}
