pragma solidity ^0.4.24;
import ;
import ;
import ;
import ;
import ;


contract bancorpricefloor is owned, tokenholder {
    using safemath for uint256;


    uint256 public constant token_price_n = 1;      
    uint256 public constant token_price_d = 100;    

    string public version = ;
    ismarttoken public token; 

    
    constructor(ismarttoken _token)
        public
        validaddress(_token)
    {
        token = _token;
    }

    
    function sell() public returns (uint256 amount) {
        uint256 allowance = token.allowance(msg.sender, this); 
        assert(token.transferfrom(msg.sender, this, allowance)); 
        uint256 ethervalue = allowance.mul(token_price_n).div(token_price_d); 
        msg.sender.transfer(ethervalue); 
        return ethervalue;
    }

    
    function withdraw(uint256 _amount) public owneronly {
        msg.sender.transfer(_amount); 
    }

    
    function() public payable {
    }
}
