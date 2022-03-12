pragma solidity ^0.4.1;

contract migrationagent {
    function migratefrom(address _from, uint256 _value);
}

contract golemnetworktoken {
    string public constant name = ;
    string public constant symbol = ;
    uint8 public constant decimals = 18;  

    
    uint256 constant percenttokensforfounder = 18;
    uint256 public constant tokencreationrate = 1000;
    
    uint256 constant tokencreationcap = 847457627118644067796611 * tokencreationrate;

    uint256 fundingstartblock;
    uint256 fundingendblock;

    address public founder;

    uint256 totaltokens;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    address public migrationagent;
    uint256 public totalmigrated;

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);
    event migrate(address indexed _from, address indexed _to, uint256 _value);

    function golemnetworktoken(address _founder, uint256 _fundingstartblock,
                               uint256 _fundingendblock) {
        founder = _founder;
        fundingstartblock = _fundingstartblock;
        fundingendblock = _fundingendblock;
    }

    

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (transferenabled() && balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = _value;
            balances[_to] += _value;
            transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transferfrom(address _from, address _to, uint256 _value)
            returns (bool success) {
        if (transferenabled() && balances[_from] >= _value &&
                allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] = _value;
            allowed[_from][msg.sender] = _value;
            transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function totalsupply() constant returns (uint256) {
        return totaltokens;
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

    

    function migrationenabled() constant returns (bool) {
        return migrationagent != 0;
    }

    function migrate(uint256 _value) {
        if (!migrationenabled()) throw;
        if (!transferenabled()) throw;
        if (balances[msg.sender] < _value) throw;
        if (_value == 0) throw;

        balances[msg.sender] = _value;
        totaltokens = _value;
        totalmigrated += _value;
        migrationagent(migrationagent).migratefrom(msg.sender, _value);
        migrate(msg.sender, migrationagent, _value);
    }

    function setmigrationagent(address _agent) external {
        if (msg.sender != founder) throw;
        if (migrationenabled()) throw;  
        migrationagent = _agent;
    }

    

    
    
    function fundinghasended() constant returns (bool) {
        if (block.number > fundingendblock)
            return true;

        
        
        return totaltokens >= tokencreationcap;
    }

    function fundingfinalized() constant returns (bool) {
        return fundingendblock == 0;
    }

    
    function fundingongoing() constant returns (bool) {
        if (fundinghasended())
            return false;
        return block.number >= fundingstartblock;
    }

    function transferenabled() constant returns (bool) {
        return fundinghasended();
    }

    
    
    function numberoftokensleft() constant returns (uint256) {
        if (fundinghasended())
            return 0;
        return tokencreationcap  totaltokens;
    }

    function changefounder(address _newfounder) external {
        
        if (msg.sender == founder)
            founder = _newfounder;
    }

    
    function() payable external {
        
        if (!fundingongoing()) throw;

        var numtokens = msg.value * tokencreationrate;
        if (numtokens == 0) throw;

        
        
        
        
        
        if (numtokens > numberoftokensleft()) throw;

        
        balances[msg.sender] += numtokens;
        totaltokens += numtokens;
        
        transfer(0, msg.sender, numtokens);
    }

    
    
    
    function transferethertofounder() external {
        
        if (msg.sender != founder) throw;
        if (!fundinghasended()) throw;

        if (!founder.send(this.balance)) throw;
    }

    
    function finalizefunding() external {
        if (fundingfinalized()) throw;
        if (msg.sender != founder) throw;
        if (!fundinghasended()) throw;

        
        var additionaltokens = totaltokens * percenttokensforfounder / (100  percenttokensforfounder);
        balances[founder] += additionaltokens;
        totaltokens += additionaltokens;

        
        
        
        fundingstartblock = 0;
        fundingendblock = 0;
    }
}
