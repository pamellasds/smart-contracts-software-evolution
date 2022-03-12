pragma solidity ^0.4.10;
import ;


contract ethertoken is erc20token {
    function ethertoken()
        erc20token(, ) {
    }

    
    function deposit() public payable returns (bool success) {
        balanceof[msg.sender] = safeadd(balanceof[msg.sender], msg.value); 
        totalsupply = safeadd(totalsupply, msg.value); 
        return true;
    }

    
    function withdraw(uint256 _amount) public returns (bool success) {
        balanceof[msg.sender] = safesub(balanceof[msg.sender], _amount); 
        totalsupply = safesub(totalsupply, _amount); 
        assert(msg.sender.send(_amount)); 
        return true;
    }

    
    function() public payable {
        deposit();
    }
}
