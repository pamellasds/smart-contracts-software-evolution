pragma solidity ^0.4.1;

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

    uint256 fundingstartblock;
    uint256 fundingendblock;

    
    bool fundingmode = true;

    address public golemfactory;

    
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

        
        
        createadditionaltokens();
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

    struct dev {
        address addr;
        uint share;
    }

    
    function createadditionaltokens() internal {
        
        
        
        

        uint256 percenttokensgolemfactory = 12;
        uint256 percenttokensdevelopers = 6;

        
        
        var devs = [
            dev(0xde00, 2500)
            dev(0xde01,  730)
            dev(0xde02,  730)
            dev(0xde03,  730)
            dev(0xde04,  730)
            dev(0xde05,  730)
            dev(0xde06,  630)
            dev(0xde07,  630)
            dev(0xde08,  630)
            dev(0xde09,  630)
            dev(0xde10,  310)
            dev(0xde11,  153)
            dev(0xde12,  150)
            dev(0xde13,  100)
            dev(0xde14,  100)
            dev(0xde15,  100)
            dev(0xde16,   70)
            dev(0xde17,   70)
            dev(0xde18,   70)
            dev(0xde19,   70)
            dev(0xde20,   70)
            dev(0xde21,   42)
            dev(0xde22,   25)
        ];

        var numadditionaltokens =
            totaltokens * (percenttokensgolemfactory + percenttokensdevelopers) /
            (100  percenttokensgolemfactory  percenttokensdevelopers);
        var numtokensfordevs =
            numadditionaltokens * percenttokensdevelopers /
            (percenttokensgolemfactory + percenttokensdevelopers);

        uint256 numtokensassigned = 0;
        var len = devs.length;
        for (uint256 i = 0; i < len; ++i) {
            var dev = devs[i];
            var n = dev.share * numtokensfordevs / 10000;
            numtokensassigned += n;
            balances[dev.addr] += n;
            
            transfer(0, dev.addr, n);
        }

        var numtokensforgolemfactory = numadditionaltokens  numtokensassigned;
        balances[golemfactory] += numtokensforgolemfactory;
        
        transfer(0, golemfactory, numtokensforgolemfactory);

        
        totaltokens += numadditionaltokens;
    }
}
