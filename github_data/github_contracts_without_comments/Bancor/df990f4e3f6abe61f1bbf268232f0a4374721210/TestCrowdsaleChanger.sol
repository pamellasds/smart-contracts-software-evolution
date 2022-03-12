pragma solidity ^0.4.10;
import ;


contract testcrowdsalechanger is crowdsalechanger {
    function testcrowdsalechanger(ismarttoken _token, iethertoken _ethertoken, uint256 _starttime, address _beneficiary, address _btcs, bytes32 _realethercaphash)
        crowdsalechanger(_token, _ethertoken, _starttime, _beneficiary, _btcs, _realethercaphash)
    {
        starttime = now  3600;
        endtime = starttime + duration;
    }
}
