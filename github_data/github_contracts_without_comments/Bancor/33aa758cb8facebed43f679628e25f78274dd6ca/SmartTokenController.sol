pragma solidity ^0.4.24;
import ;
import ;
import ;


contract smarttokencontroller is ismarttokencontroller, tokenholder {
    ismarttoken public token;   
    address public bancorx;     

    
    constructor(ismarttoken _token)
        public
        validaddress(_token)
    {
        token = _token;
    }

    
    modifier active() {
        require(token.owner() == address(this));
        _;
    }

    
    modifier inactive() {
        require(token.owner() != address(this));
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

    
    function withdrawfromtoken(ierc20token _token, address _to, uint256 _amount) public owneronly {
        itokenholder(token).withdrawtokens(_token, _to, _amount);
    }

    
    function claimtokens(address _from, uint256 _amount) public {
        
        require(msg.sender == bancorx);

        
        token.destroy(_from, _amount);
        token.issue(msg.sender, _amount);
    }

    
    function setbancorx(address _bancorx) public owneronly {
        bancorx = _bancorx;
    }
}
