pragma solidity ^0.5.16;

import ;
import ;



contract tokenstate is owned, state {
    
    mapping(address => uint) public balanceof;
    mapping(address => mapping(address => uint)) public allowance;

    constructor(address _owner, address _associatedcontract) public owned(_owner) state(_associatedcontract) {}

    

    
    function setallowance(
        address tokenowner,
        address spender,
        uint value
    ) external onlyassociatedcontract {
        allowance[tokenowner][spender] = value;
    }

    
    function setbalanceof(address account, uint value) external onlyassociatedcontract {
        balanceof[account] = value;
    }
}
