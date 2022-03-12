pragma solidity 0.4.26;
import ;
import ;
import ;
import ;


contract iconverterfactory {
    function createanchor(uint16 _type, string _name, string _symbol, uint8 _decimals) public returns (iconverteranchor);
    function createconverter(uint16 _type, iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) public returns (iconverter);

    function customfactories(uint16 _type) public view returns (itypedconvertercustomfactory) { _type; this; }
}
