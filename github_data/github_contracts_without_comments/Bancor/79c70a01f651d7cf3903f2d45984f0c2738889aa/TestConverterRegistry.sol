
pragma solidity 0.6.12;
import ;


contract testconverterregistry is converterregistry {
    iconverter public createdconverter;

    constructor(icontractregistry _registry) public converterregistry(_registry) {
    }

    function newconverter(
        uint16 _type,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint32 _maxconversionfee,
        ierc20token[] memory _reservetokens,
        uint32[] memory _reserveweights
    )
    public override returns (iconverter) {
        createdconverter = super.newconverter(_type, _name, _symbol, _decimals, _maxconversionfee, _reservetokens,
            _reserveweights);

        return createdconverter;
    }
}
