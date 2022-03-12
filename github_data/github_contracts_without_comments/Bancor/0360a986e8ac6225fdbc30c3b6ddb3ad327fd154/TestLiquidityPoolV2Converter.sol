pragma solidity 0.4.26;
import ;

contract testliquiditypoolv2converter is liquiditypoolv2converter {
    uint256 private currenttime;

    constructor(ipooltokenscontainer _token, icontractregistry _registry, uint32 _maxconversionfee)
        public liquiditypoolv2converter(_token, _registry, _maxconversionfee) {
    }

    function setreferencerateupdatetime(uint256 _referencerateupdatetime) public {
        referencerateupdatetime = _referencerateupdatetime;
    }

    function time() internal view returns (uint256) {
        return currenttime != 0 ? currenttime : now;
    }

    function settime(uint256 _currenttime) public {
        currenttime = _currenttime;
    }

    function calculateadjustedfeetest(
        uint256 _primaryreservestaked,
        uint256 _secondaryreservestaked,
        uint256 _primaryreserveweight,
        uint256 _secondaryreserveweight,
        uint256 _primaryreserverate,
        uint256 _secondaryreserverate,
        uint256 _conversionfee)
        external
        pure
        returns (uint256)
    {
        return calculateadjustedfee(
            _primaryreservestaked,
            _secondaryreservestaked,
            _primaryreserveweight,
            _secondaryreserveweight,
            _primaryreserverate,
            _secondaryreserverate,
            _conversionfee);
    }

    function setreserveweight(ierc20token _reservetoken, uint32 _weight)
        public
        validreserve(_reservetoken)
    {
        reserves[_reservetoken].weight = _weight;
    }
}
