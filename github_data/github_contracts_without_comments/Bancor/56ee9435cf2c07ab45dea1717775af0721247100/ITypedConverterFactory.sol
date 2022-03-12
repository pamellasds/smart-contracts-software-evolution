pragma solidity 0.4.26;
import ;
import ;
import ;


contract itypedconverterfactory {
    function convertertype() public pure returns (uint16);
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) public returns (iconverter);
}
