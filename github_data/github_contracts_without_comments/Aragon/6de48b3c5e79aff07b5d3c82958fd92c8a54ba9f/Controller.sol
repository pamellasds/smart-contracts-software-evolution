pragma solidity ^0.4.8;




contract controller {
    
    
    
    function proxypayment(address _owner) payable returns(bool);

    
    
    
    
    
    
    function ontransfer(address _from, address _to, uint _amount) returns(bool);

    
    
    
    
    
    
    function onapprove(address _owner, address _spender, uint _amount)
        returns(bool);
}
