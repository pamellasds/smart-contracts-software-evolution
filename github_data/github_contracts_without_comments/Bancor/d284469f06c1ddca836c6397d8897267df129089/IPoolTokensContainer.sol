
pragma solidity 0.6.12;
import ;
import ;


abstract contract ipooltokenscontainer is iconverteranchor {
    function pooltokens() external virtual view returns (ismarttoken[] memory);
    function createtoken() external virtual returns (ismarttoken);
    function mint(ismarttoken _token, address _to, uint256 _amount) external virtual;
    function burn(ismarttoken _token, address _from, uint256 _amount) external virtual;
}
