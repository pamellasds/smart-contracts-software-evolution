
pragma solidity 0.6.12;
import ;
import ;


abstract contract ipriceoracle {
    function tokenaoracle() external virtual view returns (ichainlinkpriceoracle);
    function tokenboracle() external virtual view returns (ichainlinkpriceoracle);

    function latestrate(ierc20token _tokena, ierc20token _tokenb) public virtual view returns (uint256, uint256);
    function lastupdatetime() public virtual view returns (uint256);
    function latestrateandupdatetime(ierc20token _tokena, ierc20token _tokenb) public virtual view returns (uint256, uint256, uint256);
}
