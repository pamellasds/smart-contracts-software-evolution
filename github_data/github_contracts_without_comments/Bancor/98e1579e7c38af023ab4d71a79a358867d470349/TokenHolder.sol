pragma solidity ^0.4.11;
import ;
import ;
import ;


contract tokenholder is itokenholder, owned {
    
    function tokenholder() {
    }

    
    modifier validaddress(address _address) {
        require(_address != 0x0);
        _;
    }

    
    modifier notthis(address _address) {
        require(_address != address(this));
        _;
    }

    
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount)
        public
        owneronly
        validaddress(_token)
        validaddress(_to)
        notthis(_to)
    {
        assert(_token.transfer(_to, _amount));
    }
}
