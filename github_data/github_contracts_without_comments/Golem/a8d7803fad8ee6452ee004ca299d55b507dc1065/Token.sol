pragma solidity ^0.4.4;

import ;

contract migrationagent {
    function migratefrom(address _from, uint256 _value);
}

contract golemnetworktoken {
    string public constant name = ;
    string public constant symbol = ;
    uint8 public constant decimals = 18;  

    uint256 public constant tokencreationrate = 1000;

    
    uint256 public constant tokencreationcap = 820000 ether * tokencreationrate;
    uint256 public constant tokencreationmin = 150000 ether * tokencreationrate;

    uint256 public fundingstartblock;
    uint256 public fundingendblock;

    
    bool public funding = true;

    
    address public golemfactory;

    
    address public migrationmaster;

    gntallocation public lockedallocation;

    
    uint256 totaltokens;

    mapping (address => uint256) balances;

    address public migrationagent;
    uint256 public totalmigrated;

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event migrate(address indexed _from, address indexed _to, uint256 _value);
    event refund(address indexed _from, uint256 _value);

    function golemnetworktoken(address _golemfactory,
                               address _migrationmaster,
                               uint256 _fundingstartblock,
                               uint256 _fundingendblock) {
        lockedallocation = new gntallocation(_golemfactory);
        migrationmaster = _migrationmaster;
        golemfactory = _golemfactory;
        fundingstartblock = _fundingstartblock;
        fundingendblock = _fundingendblock;
    }

    
    
    
    function transfer(address _to, uint256 _value) returns (bool) {
        
        if (funding) throw;

        var senderbalance = balances[msg.sender];
        if (senderbalance >= _value && _value > 0) {
            senderbalance = _value;
            balances[msg.sender] = senderbalance;
            balances[_to] += _value;
            transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function totalsupply() external constant returns (uint256) {
        return totaltokens;
    }

    function balanceof(address _owner) external constant returns (uint256) {
        return balances[_owner];
    }

    

    function migrate(uint256 _value) external {
        
        if (funding) throw;
        if (migrationagent == 0) throw;

        
        if (_value == 0) throw;
        if (_value > balances[msg.sender]) throw;

        balances[msg.sender] = _value;
        totaltokens = _value;
        totalmigrated += _value;
        migrationagent(migrationagent).migratefrom(msg.sender, _value);
        migrate(msg.sender, migrationagent, _value);
    }

    
    
    
    function setmigrationagent(address _agent) external {
        
        if (funding) throw;
        if (migrationagent != 0) throw;
        if (msg.sender != migrationmaster) throw;
        migrationagent = _agent;
    }

    function setmigrationmaster(address _master) external {
        if (msg.sender != migrationmaster) throw;
        migrationmaster = _master;
    }

    

    
    
    
    function() payable external {
        
        
        
        if (!funding) throw;
        if (block.number < fundingstartblock) throw;
        if (block.number > fundingendblock) throw;
        if (totaltokens >= tokencreationcap) throw;

        
        if (msg.value == 0) throw;

        
        var numtokens = msg.value * tokencreationrate;
        totaltokens += numtokens;
        if (totaltokens > tokencreationcap) throw;

        
        balances[msg.sender] += numtokens;

        
        transfer(0, msg.sender, numtokens);
    }

    
    
    
    
    
    
    function finalize() external {
        
        if (!funding) throw;
        if ((block.number <= fundingendblock ||
             totaltokens < tokencreationmin) &&
            totaltokens < tokencreationcap) throw;

        
        funding = false;

        
        if (!golemfactory.send(this.balance)) throw;

        
        
        
        
        uint256 percentoftotal = 18;
        uint256 additionaltokens =
            totaltokens * percentoftotal / (100  percentoftotal);
        totaltokens += additionaltokens;
        balances[lockedallocation] += additionaltokens;
        transfer(0, lockedallocation, additionaltokens);
    }

    
    
    
    function refund() external {
        
        if (!funding) throw;
        if (block.number <= fundingendblock) throw;
        if (totaltokens >= tokencreationmin) throw;

        var gntvalue = balances[msg.sender];
        if (gntvalue == 0) throw;
        balances[msg.sender] = 0;
        totaltokens = gntvalue;

        var ethvalue = gntvalue / tokencreationrate;
        if (!msg.sender.send(ethvalue)) throw;
        refund(msg.sender, ethvalue);
    }
}
