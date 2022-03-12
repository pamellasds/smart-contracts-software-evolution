
pragma solidity 0.6.12;
import ;


contract testconverterfactory is converterfactory {
    iconverter public createdconverter;
    iconverteranchor public createdanchor;

    function createanchor(uint16 _convertertype, string memory _name, string memory _symbol, uint8 _decimals) public override returns (iconverteranchor) {
        createdanchor = super.createanchor(_convertertype, _name, _symbol, _decimals);
        return createdanchor;
    }

    function createconverter(uint16 _type, iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) public override returns (iconverter) {
        createdconverter = super.createconverter(_type, _anchor, _registry, _maxconversionfee);
        return createdconverter;
    }
}
