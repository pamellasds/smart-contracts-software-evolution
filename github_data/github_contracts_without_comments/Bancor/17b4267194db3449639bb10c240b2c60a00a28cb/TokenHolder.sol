pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;


contract tokenholder is itokenholder, owned, utils {
    
    constructor() public {
    }

    
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount)
        public
        owneronly
        validaddress(_token)
        validaddress(_to)
        notthis(_to)
    {
        inonstandarderc20(_token).transfer(_to, _amount);
    }
}
