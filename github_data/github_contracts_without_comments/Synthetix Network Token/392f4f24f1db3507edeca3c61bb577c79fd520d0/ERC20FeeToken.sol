

pragma solidity ^0.4.19;

import ;
import ;

contract erc20feetoken is owned, safefixedmath {
    
    
    uint supply = 0;
 
    
    mapping(address => uint) balances;

    
    mapping(address => mapping (address => uint256)) allowances;

    
    
    uint public transferfee = 0;

    
    function erc20feetoken(address _owner) owned(_owner) public { }
   
    
    function totalsupply()
        public
        view
        returns (uint)
    {
        return supply;
    }
 
    
    function balanceof(address _account)
        public
        view
        returns (uint)
    {
        return balances[_account];
    }

    
    function feecharged(uint _value) 
        public
        view
        returns (uint)
    {
        return safemul(_value, transferfee);
    }

    function settransferfee(uint newfee)
        public
        onlyowner
    {
        require(newfee <= unit);
        transferfee = newfee;
        transferfeeupdated(newfee);
    }
 
    
    function transfer(address _to, uint _value)
        public
        returns (bool)
    {
        
        uint totalcharge = safeadd(_value, feecharged(_value));
        if (subissafe(balances[msg.sender], totalcharge) &&
            addissafe(balances[_to], _value)) {
            transfer(msg.sender, _to, _value);
            
            
            if (_value == 0) {
                return true;
            }
            balances[msg.sender] = safesub(balances[msg.sender], totalcharge);
            balances[_to] = safeadd(balances[_to], _value);
            return true;
        }
        return false;
    }
 
    
    function transferfrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        
        uint totalcharge = safeadd(_value, feecharged(_value));
        if (subissafe(balances[_from], totalcharge) &&
            subissafe(allowances[_from][msg.sender], totalcharge) &&
            addissafe(balances[_to], _value)) {
                transfer(_from, _to, _value);
                
                
                if (_value == 0) {
                    return true;
                }
                balances[_from] = safesub(balances[_from], totalcharge);
                allowances[_from][msg.sender] = safesub(allowances[_from][msg.sender], totalcharge);
                balances[_to] = safeadd(balances[_to], _value);
                return true;
        }
        return false;
    }
  
    
    
    
    function approve(address _spender, uint _value)
        public
        returns (bool)
    {
        allowances[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }
 
    
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint)
    {
        return allowances[_owner][_spender];
    }
 
    
    event transfer(address indexed _from, address indexed _to, uint _value);
 
    
    event approval(address indexed _owner, address indexed _spender, uint _value);

    
    event transferfeeupdated(uint newfee);
}

