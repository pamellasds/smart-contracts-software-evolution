
pragma solidity 0.6.12;
import ;
import ;
import ;


interface iliquiditypoolv2converter is iconverter {
    function reservestakedbalance(ierc20token _reservetoken) external view returns (uint256);
    function setreservestakedbalance(ierc20token _reservetoken, uint256 _balance) external;

    function primaryreservetoken() external view returns (ierc20token);

    function priceoracle() external view returns (ipriceoracle);

    function activate(ierc20token _primaryreservetoken, ichainlinkpriceoracle _primaryreserveoracle, ichainlinkpriceoracle _secondaryreserveoracle) external;
}
