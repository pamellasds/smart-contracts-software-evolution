

import ;

pragma solidity ^0.4.8;

contract humanstandardtoken is standardtoken {

    

    
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = ;       

    function humanstandardtoken(
        uint256 _initialamount,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol
        ) {
        balances[msg.sender] = _initialamount;               
        totalsupply = _initialamount;                        
        name = _tokenname;                                   
        decimals = _decimalunits;                            
        symbol = _tokensymbol;                               
    }

    
    function approveandcall(address _spender, uint256 _value, bytes _extradata) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);

        
        
        
        require(_spender.call(bytes4(bytes32(sha3())), msg.sender, _value, this, _extradata));
        return true;
    }
}
