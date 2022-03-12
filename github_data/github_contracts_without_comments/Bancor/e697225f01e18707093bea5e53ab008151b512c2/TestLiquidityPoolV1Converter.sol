
pragma solidity 0.6.12;
import ;

contract testliquiditypoolv1converter is liquiditypoolv1converter {
    uint256 public currenttime;

    constructor(
        idstoken _token,
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

    function time() internal view override returns (uint256) {
        return currenttime != 0 ? currenttime : now;
    }

    function settime(uint256 _currenttime) public {
        currenttime = _currenttime;
    }
}
