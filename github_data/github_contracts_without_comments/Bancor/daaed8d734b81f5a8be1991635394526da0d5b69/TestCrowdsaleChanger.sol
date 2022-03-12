pragma solidity ^0.4.11;
import ;


contract testcrowdsalechanger is crowdsalechanger {
    function testcrowdsalechanger(
        ismarttoken _token,
        iethertoken _ethertoken,
        uint256 _starttime,
        address _beneficiary,
        address _btcs,
        bytes32 _realethercaphash,
        uint256 _starttimeoverride)
        crowdsalechanger(_token, _ethertoken, _starttime, _beneficiary, _btcs, _realethercaphash)
    {
        starttime = _starttimeoverride;
        endtime = starttime + duration;
    }
}
