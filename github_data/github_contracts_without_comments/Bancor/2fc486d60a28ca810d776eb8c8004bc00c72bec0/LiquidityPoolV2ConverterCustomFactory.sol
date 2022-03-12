pragma solidity 0.4.26;
import ;
import ;


contract liquiditypoolv2convertercustomfactory is itypedconvertercustomfactory {
    
    function convertertype() public pure returns (uint16) {
        return 2;
    }

    
    function createpriceoracle(
        ierc20token _primaryreservetoken,
        ierc20token _secondaryreservetoken,
        ichainlinkpriceoracle _primaryreserveoracle,
        ichainlinkpriceoracle _secondaryreserveoracle)
        public
        returns (ipriceoracle)
    {
        return new priceoracle(_primaryreservetoken, _secondaryreservetoken, _primaryreserveoracle, _secondaryreserveoracle);
    }
}
