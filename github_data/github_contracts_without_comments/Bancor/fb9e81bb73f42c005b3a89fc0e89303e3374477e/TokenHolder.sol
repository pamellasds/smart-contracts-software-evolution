
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;
import ;


contract tokenholder is itokenholder, tokenhandler, owned, utils {
    
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount)
        public
        virtual
        override
        owneronly
        validaddress(address(_token))
        validaddress(_to)
        notthis(_to)
    {
        safetransfer(_token, _to, _amount);
    }
}
