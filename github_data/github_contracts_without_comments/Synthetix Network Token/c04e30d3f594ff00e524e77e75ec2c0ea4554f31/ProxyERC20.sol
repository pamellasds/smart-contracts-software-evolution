pragma solidity ^0.5.16;


import ;
import ;



contract proxyerc20 is proxy, ierc20 {
    constructor(address _owner) public proxy(_owner) {}

    

    function name() public view returns (string memory) {
        
        return ierc20(address(target)).name();
    }

    function symbol() public view returns (string memory) {
        
        return ierc20(address(target)).symbol();
    }

    function decimals() public view returns (uint8) {
        
        return ierc20(address(target)).decimals();
    }

    

    
    function totalsupply() public view returns (uint256) {
        
        return ierc20(address(target)).totalsupply();
    }

    
    function balanceof(address account) public view returns (uint256) {
        
        return ierc20(address(target)).balanceof(account);
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        
        return ierc20(address(target)).allowance(owner, spender);
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        
        target.setmessagesender(msg.sender);

        
        ierc20(address(target)).transfer(to, value);

        
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        
        target.setmessagesender(msg.sender);

        
        ierc20(address(target)).approve(spender, value);

        
        return true;
    }

    
    function transferfrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        
        target.setmessagesender(msg.sender);

        
        ierc20(address(target)).transferfrom(from, to, value);

        
        return true;
    }
}
