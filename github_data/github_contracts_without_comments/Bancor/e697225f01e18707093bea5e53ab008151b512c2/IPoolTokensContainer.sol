
pragma solidity 0.6.12;
import ;
import ;


interface ipooltokenscontainer is iconverteranchor {
    function pooltokens() external view returns (idstoken[] memory);
    function createtoken() external returns (idstoken);
    function mint(idstoken _token, address _to, uint256 _amount) external;
    function burn(idstoken _token, address _from, uint256 _amount) external;
}
