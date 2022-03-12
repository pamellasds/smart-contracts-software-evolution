
pragma solidity 0.6.12;
import ;
import ;


interface ipooltokenscontainer is iconverteranchor {
    function pooltokens() external view returns (ismarttoken[] memory);
    function createtoken() external returns (ismarttoken);
    function mint(ismarttoken _token, address _to, uint256 _amount) external;
    function burn(ismarttoken _token, address _from, uint256 _amount) external;
}
