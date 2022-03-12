pragma solidity ^0.4.24;
import ;


contract testcrowdsalecontroller is crowdsalecontroller {
    using safemath for uint256;

    
    uint256 public constant btcs_ether_cap_small = 2 ether; 

    constructor(
        ismarttoken _token,
        uint256 _starttime,
        address _beneficiary,
        address _btcs,
        bytes32 _realethercaphash,
        uint256 _starttimeoverride)
        public
        crowdsalecontroller(_token, _starttime, _beneficiary, _btcs, _realethercaphash)
    {
        starttime = _starttimeoverride;
        endtime = starttime + duration;
    }

    modifier btcsethercapnotreached(uint256 _ethcontribution) {
        assert(totalethercontributed.add(_ethcontribution) <= btcs_ether_cap_small);
        _;
    }
}
