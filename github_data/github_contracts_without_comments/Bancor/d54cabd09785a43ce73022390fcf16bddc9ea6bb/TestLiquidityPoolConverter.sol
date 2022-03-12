
pragma solidity 0.6.12;
import ;

contract testliquiditypoolconverter is liquiditypoolv1converter {
    constructor(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee
    )
        liquiditypoolv1converter(_token, _registry, _maxconversionfee)
        public
    {
    }

    function setethertoken(iethertoken _ethertoken) public {
        ethertoken = _ethertoken;
    }
}
