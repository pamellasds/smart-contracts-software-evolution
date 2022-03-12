pragma solidity 0.4.26;
import ;

contract testliquiditypoolv2converter is liquiditypoolv2converter {
    uint256 internal currenttime;

    constructor(ipooltokenscontainer _token, icontractregistry _registry, uint32 _maxconversionfee)
        public liquiditypoolv2converter(_token, _registry, _maxconversionfee) {
    }

    function time() internal view returns (uint256) {
        return currenttime != 0 ? currenttime : now;
    }

    function settime(uint256 _currenttime) public {
        currenttime = _currenttime;
    }

    function setprevconversiontime(uint256 _prevconversiontime) public {
        prevconversiontime = _prevconversiontime;
    }

    function calculatefeetest(
        ierc20token _sourcetoken,
        ierc20token _targettoken,
        uint32 _sourceweight,
        uint32 _targetweight,
        uint256 _externalraten,
        uint256 _externalrated,
        uint32 _targetexternalweight,
        uint256 _targetamount)
        external
        view
        returns (uint256)
    {
        return calculatefee(
            _sourcetoken,
            _targettoken,
            _sourceweight,
            _targetweight,
            fraction(_externalraten, _externalrated),
            _targetexternalweight,
            _targetamount);
    }

    function normalizedratiotest(uint256 _a, uint256 _b, uint256 _scale) external pure returns (uint256, uint256) {
        return normalizedratio(_a, _b, _scale);
    }

    function accurateratiotest(uint256 _a, uint256 _b, uint256 _scale) external pure returns (uint256, uint256) {
        return accurateratio(_a, _b, _scale);
    }

    function reducedratiotest(uint256 _n, uint256 _d, uint256 _max) external pure returns (uint256, uint256) {
        return reducedratio(_n, _d, _max);
    }

    function rounddivtest(uint256 _n, uint256 _d) external pure returns (uint256) {
        return rounddiv(_n, _d);
    }

    function weightedaverageintegerstest(uint256 _x, uint256 _y, uint256 _n, uint256 _d) external pure returns (uint256) {
        return weightedaverageintegers(_x, _y, _n, _d);
    }

    function compareratestest(uint256 _xn, uint256 _xd, uint256 _yn, uint256 _yd) external pure returns (int8) {
        return comparerates(fraction(_xn, _xd), fraction(_yn, _yd));
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
