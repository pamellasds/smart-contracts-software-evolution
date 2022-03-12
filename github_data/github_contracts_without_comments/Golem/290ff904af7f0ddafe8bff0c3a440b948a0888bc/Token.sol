pragma solidity ^0.4.1;

contract migrationagent {
    function migratefrom(address _from, uint256 _value);
}

contract golemnetworktoken {
    string public constant name = ;
    string public constant symbol = ;
    uint8 public constant decimals = 18;  

    uint256 constant percenttokensgolemfactory = 12;
    uint256 constant percenttokensdevelopers = 6;
    uint256 public constant tokencreationrate = 1000;

    
    uint256 public constant tokencreationcap = 820000 ether * tokencreationrate;
    uint256 public constant tokencreationmin = 150000 ether * tokencreationrate;

    uint256 fundingstartblock;
    uint256 fundingendblock;

    
    bool fundingmode = true;

    address public golemfactory;

    
    
    
    
    
    address public constant dev0 = 0xde00;
    uint256 public constant dev0percent = 10;

    address public constant dev1 = 0xde01;
    uint256 public constant dev1percent = 10;

    address public constant dev2 = 0xde02;
    uint256 public constant dev2percent = 15;

    address public constant dev3 = 0xde03;
    uint256 public constant dev3percent = 20;

    address public constant dev4 = 0xde04;
    uint256 public constant dev4percent = 20;

    address public constant dev5 = 0xde05;
    

    
    uint256 totaltokens;

    mapping (address => uint256) balances;

    address public migrationagent;
    uint256 public totalmigrated;

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event migrate(address indexed _from, address indexed _to, uint256 _value);
    event refund(address indexed _from, uint256 _value);

    
    modifier infundingactive {
        if (!fundingmode) throw;
        
        if (block.number < fundingstartblock ||
            block.number > fundingendblock ||
            totaltokens >= tokencreationcap) throw;
        _;
    }

    
    modifier infundingfailure {
        if (!fundingmode) throw;
        
        if (block.number <= fundingendblock ||
            totaltokens >= tokencreationmin) throw;
        _;
    }

    
    modifier infundingsuccess {
        if (!fundingmode) throw;
        
        if ((block.number <= fundingendblock ||
             totaltokens < tokencreationmin) &&
            totaltokens < tokencreationcap) throw;
        _;
    }

    
    modifier inoperational {
        if (fundingmode) throw;
        _;
    }

    
    modifier innormal {
        if (fundingmode) throw;
        if (migrationagent != 0) throw;
        _;
    }

    
    modifier inmigration {
        if (fundingmode) throw;
        if (migrationagent == 0) throw;
        _;
    }

    function golemnetworktoken(address _golemfactory,
                               uint256 _fundingstartblock,
                               uint256 _fundingendblock) {
        golemfactory = _golemfactory;
        fundingstartblock = _fundingstartblock;
        fundingendblock = _fundingendblock;
    }

    function transfer(address _to, uint256 _value) inoperational returns (bool) {
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

    

    function migrate(uint256 _value) inmigration external {
        if (_value == 0 || _value > balances[msg.sender]) throw;

        balances[msg.sender] = _value;
        totaltokens = _value;
        totalmigrated += _value;
        migrationagent(migrationagent).migratefrom(msg.sender, _value);
        migrate(msg.sender, migrationagent, _value);
    }

    function setmigrationagent(address _agent) innormal external {
        if (msg.sender != golemfactory) throw;

        migrationagent = _agent;
    }

    

    function fundingactive() constant external returns (bool) {
        
        if (!fundingmode) return false;

        
        if (block.number < fundingstartblock ||
            block.number > fundingendblock ||
            totaltokens >= tokencreationcap) return false;
        return true;
    }

    
    function numberoftokensleft() constant external returns (uint256) {
        if (!fundingmode) return 0;
        if (block.number > fundingendblock) return 0;
        return tokencreationcap  totaltokens;
    }

    function finalized() constant external returns (bool) {
        return !fundingmode;
    }

    function changegolemfactory(address _golemfactory) inoperational external {
        if (msg.sender == golemfactory)
            golemfactory = _golemfactory;
    }

    
    
    function() payable infundingactive external {
        if (msg.value == 0) throw;

        
        var numtokens = msg.value * tokencreationrate;
        totaltokens += numtokens;
        if (totaltokens > tokencreationcap) throw;

        
        balances[msg.sender] += numtokens;

        
        transfer(0, msg.sender, numtokens);
    }

    
    
    
    
    
    function finalize() infundingsuccess external {
        
        fundingmode = false;

        
        if (!golemfactory.send(this.balance)) throw;

        
        var numadditionaltokens =
            totaltokens * (percenttokensgolemfactory + percenttokensdevelopers) /
            (100  percenttokensgolemfactory  percenttokensdevelopers);
        var numtokensforgolemagent =
            numadditionaltokens * percenttokensgolemfactory /
            (percenttokensgolemfactory + percenttokensdevelopers);

        balances[golemfactory] += numtokensforgolemagent;

        
        var numtokensfordevelpers  = numadditionaltokens  numtokensforgolemagent;

        var dev0tokens = dev0percent * numtokensfordevelpers / 100;
        var dev1tokens = dev1percent * numtokensfordevelpers / 100;
        var dev2tokens = dev2percent * numtokensfordevelpers / 100;
        var dev3tokens = dev3percent * numtokensfordevelpers / 100;
        var dev4tokens = dev4percent * numtokensfordevelpers / 100;
        var dev5tokens = numtokensfordevelpers  dev0tokens  dev1tokens 
                         dev2tokens  dev3tokens  dev4tokens;

        balances[dev0] += dev0tokens;
        balances[dev1] += dev1tokens;
        balances[dev2] += dev2tokens;
        balances[dev3] += dev3tokens;
        balances[dev4] += dev4tokens;
        balances[dev5] += dev5tokens;

        
        totaltokens += numadditionaltokens;
    }

    function refund() infundingfailure external {
        var gntvalue = balances[msg.sender];
        if (gntvalue == 0) throw;
        balances[msg.sender] = 0;
        totaltokens = gntvalue;

        var ethvalue = gntvalue / tokencreationrate;
        if (!msg.sender.send(ethvalue)) throw;
        refund(msg.sender, ethvalue);
    }
}
