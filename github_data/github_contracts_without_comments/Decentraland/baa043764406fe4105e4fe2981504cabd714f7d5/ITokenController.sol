pragma solidity ^0.4.24;




interface itokencontroller {
    
    
    
    function proxypayment(address _owner) external payable returns(bool);

    
    
    
    
    
    
    function ontransfer(address _from, address _to, uint _amount) external returns(bool);

    
    
    
    
    
    
    function onapprove(address _owner, address _spender, uint _amount) external returns(bool);
}