pragma solidity ^0.4.23;
import ;
import ;


contract smarttokencontroller is tokenholder {
    ismarttoken public token;   

    
    constructor(ismarttoken _token)
        public
        validaddress(_token)
    {
        token = _token;
    }

    
    modifier active() {
        assert(token.owner() == address(this));
        _;
    }

    
    modifier inactive() {
        assert(token.owner() != address(this));
        _;
    }

    
    function transfertokenownership(address _newowner) public owneronly {
        token.transferownership(_newowner);
    }

    
    function accepttokenownership() public owneronly {
        token.acceptownership();
    }

    
    function disabletokentransfers(bool _disable) public owneronly {
        token.disabletransfers(_disable);
    }

    
    function withdrawfromtoken(
        ierc20token _token, 
        address _to, 
        uint256 _amount
    ) 
        public
        owneronly
    {
        itokenholder(token).withdrawtokens(_token, _to, _amount);
    }
}
