

pragma solidity 0.4.25;


import ;


contract tokenstate is state {

    
    mapping(address => uint) public balanceof;
    mapping(address => mapping(address => uint)) public allowance;

    
    constructor(address _owner, address _associatedcontract)
        state(_owner, _associatedcontract)
        public
    {}

    

    
    function setallowance(address tokenowner, address spender, uint value)
        external
        onlyassociatedcontract
    {
        allowance[tokenowner][spender] = value;
    }

    
    function setbalanceof(address account, uint value)
        external
        onlyassociatedcontract
    {
        balanceof[account] = value;
    }
}
