

pragma solidity >=0.4.10;

import ;
import ;



contract tokenreceivable is owned {
    function claimtokens(address _token, address _to) onlyowner returns (bool) {
        itoken token = itoken(_token);
        return token.transfer(_to, token.balanceof(this));
    }
}
