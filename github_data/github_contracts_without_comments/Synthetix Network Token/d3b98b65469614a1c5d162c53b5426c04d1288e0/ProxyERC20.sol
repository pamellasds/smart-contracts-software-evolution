

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;

contract proxyerc20 is proxy, ierc20 {

    constructor(address _owner)
        proxy(_owner)
        public
    {}

    

    function name() public view returns (string){
        
        return ierc20(target).name();
    }

    function symbol() public view returns (string){
         
        return ierc20(target).symbol();
    }

    function decimals() public view returns (uint8){
         
        return ierc20(target).decimals();
    }

    

    
    function totalsupply() public view returns (uint256) {
        
        return ierc20(target).totalsupply();
    }

    
    function balanceof(address account) public view returns (uint256) {
        
        return ierc20(target).balanceof(account);
    }

    
    function allowance(
        address owner,
        address spender
    )
        public
        view
        returns (uint256)
    {
        
        return ierc20(target).allowance(owner, spender);
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        
        target.setmessagesender(msg.sender);

        
        ierc20(target).transfer(to, value);

        
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        
        target.setmessagesender(msg.sender);

        
        ierc20(target).approve(spender, value);

        
        return true;
    }

    
    function transferfrom(
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        
        target.setmessagesender(msg.sender);

        
        ierc20(target).transferfrom(from, to, value);

        
        return true;
    }
}
