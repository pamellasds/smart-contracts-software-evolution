pragma solidity ^0.4.21;
import ;


contract testcrowdsalecontroller is crowdsalecontroller {
    function testcrowdsalecontroller(
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
}
