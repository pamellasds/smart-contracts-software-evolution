pragma solidity 0.4.26;
import ;
import ;


contract ipooltokenscontainer is iconverteranchor {
    function pooltokens() public view returns (ismarttoken[]);
    function createtoken() public returns (ismarttoken);
    function mint(ismarttoken _token, address _to, uint256 _amount) public;
    function burn(ismarttoken _token, address _from, uint256 _amount) public;
}
