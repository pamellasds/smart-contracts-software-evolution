
pragma solidity 0.6.12;
import ;

contract testliquiditypoolv2converter is liquiditypoolv2converter {
    uint256 public currenttime;

    constructor(ipooltokenscontainer _token, icontractregistry _registry, uint32 _maxconversionfee)
        public liquiditypoolv2converter(_token, _registry, _maxconversionfee) {
    }

    function setexternalrateupdatetime(uint256 _externalrateupdatetime) public {
        externalrateupdatetime = _externalrateupdatetime;
    }

    function time() internal view override returns (uint256) {
        return currenttime != 0 ? currenttime : now;
    }

    function settime(uint256 _currenttime) public {
        currenttime = _currenttime;
    }

    function setreserveweight(ierc20token _reservetoken, uint32 _weight)
        public
        validreserve(_reservetoken)
    {
        reserves[_reservetoken].weight = _weight;

        if (_reservetoken == primaryreservetoken) {
            reserves[secondaryreservetoken].weight = ppm_resolution  _weight;
        }
        else {
            reserves[primaryreservetoken].weight = ppm_resolution  _weight;
        }
    }
}
