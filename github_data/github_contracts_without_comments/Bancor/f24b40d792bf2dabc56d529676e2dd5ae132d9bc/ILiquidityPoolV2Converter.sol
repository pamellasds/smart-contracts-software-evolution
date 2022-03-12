pragma solidity 0.4.26;
import ;
import ;


contract iliquiditypoolv2converter {
    function reservestakedbalance(ierc20token _reservetoken) public view returns (uint256);
    function setreservestakedbalance(ierc20token _reservetoken, uint256 _balance) public;

    function primaryreservetoken() public view returns (ierc20token);

    function priceoracle() public view returns (ipriceoracle);

    function activate(ierc20token _primaryreservetoken, ichainlinkpriceoracle _primaryreserveoracle, ichainlinkpriceoracle _secondaryreserveoracle) public;
}
