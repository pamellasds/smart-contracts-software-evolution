pragma solidity ^0.4.8;
import ;



contract ethertoken is erc20token {
    function ethertoken(string _name, string _symbol)
        erc20token(, ) {
    }

    
    function deposit() public payable returns (bool success) {
        if (balanceof[msg.sender] + msg.value < balanceof[msg.sender]) 
            throw;

        balanceof[msg.sender] += msg.value;
        return true;
    }

    
    function withdraw(uint256 _amount) public returns (bool success) {
        if (balanceof[msg.sender] < _amount) 
            throw;

        
        balanceof[msg.sender] = _amount;
        
        if (!msg.sender.send(_amount))
            throw;

        return true;
    }

    
    function() public payable {
        if (balanceof[msg.sender] + msg.value < balanceof[msg.sender]) 
            throw;

        balanceof[msg.sender] += msg.value;
    }
}
