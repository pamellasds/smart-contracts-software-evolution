
pragma solidity 0.6.12;
import ;
import ;


contract liquiditypoolv2convertercustomfactory is itypedconvertercustomfactory {
    
    function convertertype() external pure override returns (uint16) {
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
