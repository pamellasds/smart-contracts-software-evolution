
pragma solidity 0.6.12;
import ;
import ;


interface ipriceoracle {
    function tokenaoracle() external view returns (ichainlinkpriceoracle);
    function tokenboracle() external view returns (ichainlinkpriceoracle);

    function latestrate(ierc20token _tokena, ierc20token _tokenb) external view returns (uint256, uint256);
    function lastupdatetime() external view returns (uint256);
    function latestrateandupdatetime(ierc20token _tokena, ierc20token _tokenb) external view returns (uint256, uint256, uint256);
}
