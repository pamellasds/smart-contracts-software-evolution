pragma solidity ^0.4.1;




contract erc20tokeninterface {
    
    function totalsupply() constant returns (uint256 supply);

    
    
    function balanceof(address _owner) constant returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success);

    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _value) returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract balancedb {
    address owner;
    address controller;
    mapping (address => uint256) balances;

    function balanceof(address _addr) constant returns (uint256 balance) {
        return balances[_addr];
    }

    function setbalanceof(address _addr, uint256 _value) {
        if (msg.sender == controller)
            balances[_addr] = _value;
    }

    function changecontroller(address _newcontroller) {
        if (msg.sender == owner)
            controller = _newcontroller;
    }

    function changeowner(address _newowner) {
        if (msg.sender == owner)
            owner = _newowner;
    }
}

contract standardtoken is erc20tokeninterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    function transfer(address _to, uint256 _value) returns (bool success) {
        

        
        
        
        
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = _value;
            balances[_to] += _value;
            transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferfrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] = _value;
            allowed[_from][msg.sender] = _value;
            transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceof(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}

contract golemnetworktoken is standardtoken {

    

    string public standard = ;

    uint256 supply = 0;
    string public constant name = ;
    uint8 public constant decimals = 10^18; 
    string public constant symbol = ;

    uint256 constant percenttokensforfounder = 18;
    uint256 constant tokensperwei = 1;
    uint256 constant fundingmax = 847457627118644067796611 * tokensperwei;
    uint256 fundingstart;
    uint256 fundingend;
    address founder;

    function golemnetworktoken(address _founder, uint256 _fundingstart,
                               uint256 _fundingend) {
        founder = _founder;
        fundingstart = _fundingstart;
        fundingend = _fundingend;
    }

    
    
    function fundinghasended() constant returns (bool) {
        if (block.number > fundingend)
            return true;

        
        return supply == fundingmax;
    }

    
    function fundingongoing() constant returns (bool) {
        if (fundinghasended())
            return false;
        return block.number >= fundingstart;
    }

    
    
    function numberoftokensleft() constant returns (uint256) {
        return fundingmax  supply;
    }

    function changefounder(address _newfounder) external {
        
        if (msg.sender == founder)
            founder = _newfounder;
    }

    function totalsupply() constant returns (uint256 supply) {
        return supply;
    }

    
    function() external {
        
        if (!fundingongoing()) throw;

        var numtokens = msg.value * tokensperwei;
        if (numtokens == 0) throw;

        
        
        
        
        
        if (numtokens > numberoftokensleft()) throw;

        
        balances[msg.sender] += numtokens;
        supply += numtokens;
        
    }

    
    
    
    function transferethertofounder() external {
        
        if (msg.sender != founder) throw;
        if (!fundinghasended()) throw;

        if (!founder.send(this.balance)) throw;
    }

    
    function finalizefunding() external {
        if (fundingend == 0) throw;
        if (msg.sender != founder) throw;
        if (!fundinghasended()) throw;

        
        var additionaltokens = supply * (100 + percenttokensforfounder) / 100;
        balances[founder] += additionaltokens;
        supply += additionaltokens;

        
        
        
        fundingstart = 0;
        fundingend = 0;
    }
}
