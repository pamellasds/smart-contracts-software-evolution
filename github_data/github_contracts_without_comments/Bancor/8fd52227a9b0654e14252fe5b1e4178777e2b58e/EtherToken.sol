pragma solidity ^0.4.10;
import ;


contract ethertoken is erc20token {
    function ethertoken()
        erc20token(, , 18) {
    }

    
    modifier validamount(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    
    function deposit()
        public
        validamount(msg.value)
        payable
    {
        balanceof[msg.sender] = safeadd(balanceof[msg.sender], msg.value); 
        totalsupply = safeadd(totalsupply, msg.value); 
    }

    
    function withdraw(uint256 _amount)
        public
        validamount(_amount)
    {
        balanceof[msg.sender] = safesub(balanceof[msg.sender], _amount); 
        totalsupply = safesub(totalsupply, _amount); 
        assert(msg.sender.send(_amount)); 
    }

    
    function() public payable {
        deposit();
    }
}
