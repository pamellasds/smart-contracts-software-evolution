
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;


interface iconverterfactory {
    function createanchor(uint16 _type, string memory _name, string memory _symbol, uint8 _decimals) external returns (iconverteranchor);
    function createconverter(uint16 _type, iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) external returns (iconverter);

    function customfactories(uint16 _type) external view returns (itypedconvertercustomfactory);
}
