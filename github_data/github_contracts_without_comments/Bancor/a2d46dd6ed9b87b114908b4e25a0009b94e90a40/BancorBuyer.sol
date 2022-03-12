pragma solidity ^0.4.11;
import ;
import ;
import ;
import ;


contract ibancorchanger is itokenchanger {
    function token() public constant returns (ismarttoken _token) { _token; }
    function getreservebalance(ierc20token _reservetoken) public constant returns (uint256 balance);
}


contract bancorbuyer is tokenholder {
    string public version = ;
    ibancorchanger public tokenchanger; 
    iethertoken public ethertoken;      

    
    function bancorbuyer(ibancorchanger _changer, iethertoken _ethertoken)
        validaddress(_changer)
        validaddress(_ethertoken)
    {
        tokenchanger = _changer;
        ethertoken = _ethertoken;

        
        tokenchanger.getreservebalance(ethertoken);
    }

    
    function buy(uint256 _minreturn) public payable returns (uint256 amount) {
        ethertoken.deposit.value(msg.value)(); 
        assert(ethertoken.approve(tokenchanger, 0)); 
        assert(ethertoken.approve(tokenchanger, msg.value)); 

        ismarttoken smarttoken = tokenchanger.token();
        uint256 returnamount = tokenchanger.change(ethertoken, smarttoken, msg.value, _minreturn); 
        assert(smarttoken.transfer(msg.sender, returnamount)); 
        return returnamount;
    }

    
    function() payable {
        buy(1);
    }
}
