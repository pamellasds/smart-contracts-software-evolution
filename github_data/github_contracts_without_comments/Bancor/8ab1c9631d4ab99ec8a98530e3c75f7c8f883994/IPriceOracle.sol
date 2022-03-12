pragma solidity 0.4.26;
import ;
import ;


contract ipriceoracle {
    function latestrate(ierc20token _tokena, ierc20token _tokenb) public view returns (uint256, uint256);
    function lastupdatetime() public view returns (uint256);
    function latestrateandupdatetime(ierc20token _tokena, ierc20token _tokenb) public view returns (uint256, uint256, uint256);

    function tokenaoracle() public view returns (ichainlinkpriceoracle) {this;}
    function tokenboracle() public view returns (ichainlinkpriceoracle) {this;}
}
