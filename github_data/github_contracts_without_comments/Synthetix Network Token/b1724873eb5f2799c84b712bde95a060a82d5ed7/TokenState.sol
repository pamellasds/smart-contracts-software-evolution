

pragma solidity 0.4.21;


import ;


contract tokenstate is owned {

    
    address public associatedcontract;

    
    mapping(address => uint) public balanceof;
    mapping(address => mapping(address => uint)) public allowance;

    
    function tokenstate(address _owner, address _associatedcontract)
        owned(_owner)
        public
    {
        associatedcontract = _associatedcontract;
        emit associatedcontractupdated(_associatedcontract);
    }

    

    
    function setassociatedcontract(address _associatedcontract)
        external
        onlyowner
    {
        associatedcontract = _associatedcontract;
        emit associatedcontractupdated(_associatedcontract);
    }

    
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


    

    modifier onlyassociatedcontract
    {
        require(msg.sender == associatedcontract);
        _;
    }

    

    event associatedcontractupdated(address _associatedcontract);
}
