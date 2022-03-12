
pragma solidity 0.6.12;
import ;
import ;
import ;


abstract contract iliquiditypoolv2converter is iconverter {
    function reservestakedbalance(ierc20token _reservetoken) public virtual view returns (uint256);
    function setreservestakedbalance(ierc20token _reservetoken, uint256 _balance) public virtual;

    function primaryreservetoken() public virtual view returns (ierc20token);

    function priceoracle() public virtual view returns (ipriceoracle);

    function activate(ierc20token _primaryreservetoken, ichainlinkpriceoracle _primaryreserveoracle, ichainlinkpriceoracle _secondaryreserveoracle) public virtual;
}
