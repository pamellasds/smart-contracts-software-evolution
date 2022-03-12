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

    gntallocation lockedallocation;

    
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

        if (_golemfactory == 0) throw;
        if (_migrationmaster == 0) throw;
        if (_fundingstartblock <= block.number) throw;
        if (_fundingendblock   <= _fundingstartblock) throw;

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
        if (_master == 0) throw;
        migrationmaster = _master;
    }

    

    
    
    
    function create() payable external {
        
        
        
        if (!funding) throw;
        if (block.number < fundingstartblock) throw;
        if (block.number > fundingendblock) throw;

        
        if (msg.value == 0) throw;
        if (msg.value > (tokencreationcap  totaltokens) / tokencreationrate)
            throw;

        var numtokens = msg.value * tokencreationrate;
        totaltokens += numtokens;

        
        balances[msg.sender] += numtokens;

        
        transfer(0, msg.sender, numtokens);
    }

    
    
    
    
    
    
    function finalize() external {
        
        if (!funding) throw;
        if ((block.number <= fundingendblock ||
             totaltokens < tokencreationmin) &&
            totaltokens < tokencreationcap) throw;

        
        funding = false;

        
        
        
        
        uint256 percentoftotal = 18;
        uint256 additionaltokens =
            totaltokens * percentoftotal / (100  percentoftotal);
        totaltokens += additionaltokens;
        balances[lockedallocation] += additionaltokens;
        transfer(0, lockedallocation, additionaltokens);

        
        if (!golemfactory.send(this.balance)) throw;
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
        refund(msg.sender, ethvalue);
        if (!msg.sender.send(ethvalue)) throw;
    }
}
pragma solidity ^0.4.4;

import ;



contract gntallocation {
    
    
    
    
    uint256 constant totalallocations = 30000;

    
    mapping (address => uint256) allocations;

    golemnetworktoken gnt;
    uint256 unlockedat;

    uint256 tokenscreated = 0;

    function gntallocation(address _golemfactory) internal {
        gnt = golemnetworktoken(msg.sender);
        unlockedat = now + 6 * 30 days;

        
        allocations[_golemfactory] = 20000; 

        
        allocations[0x9d3f257827b17161a098d380822fa2614ff540c8] = 2500; 
        allocations[0xd7406e50b73972fa4aa533a881af68b623ba3f66] =  730; 
        allocations[0xd15356d05a7990de7ec94304b0fd538e550c09c0] =  730;
        allocations[0x3971d17b62b825b151760e2451f818bfb64489a7] =  730;
        allocations[0x95e337d09f1bc67681b1cab7ed1125ea2bae5ca8] =  730;
        allocations[0x0025c58db686b8cece05cb8c50c1858b63aa396e] =  730;
        allocations[0xb127fc62de6ca30aac9d551591daeddebb2efd7a] =  630; 
        allocations[0x21af2e2c240a71e9fb84e90d71c2b2adde0d0e81] =  630;
        allocations[0x682aa1c3b3e102acb9c97b861d595f9fbff0f1b8] =  630;
        allocations[0x6edd429c77803606cbd6bb501cc701a6cad6be01] =  630;
        allocations[0x5e455624372fe11b39464e93d41d1f6578c3d9f6] =  310; 
        allocations[0xb7c7ead515ca275d53e30b39d8ebedb3f19da244] =  138; 
        allocations[0xd513b1c3fe31f3fe0b1e42aa8f55e903f19f1730] =  135; 
        allocations[0x70cac7f8e404eefce6526823452e428b5ab09b00] =  100; 
        allocations[0xe0d5861e7be0fac6c85ecde6e8bf76b046a96149] =  100;
        allocations[0x17488694d2fee4377ec718836bb9d4910e81d9cf] =  100;
        allocations[0xb481372086dec3ca2fccd3eb2f462c9c893ef3c5] =  100;
        allocations[0xfb6d91e69cd7990651f26a3aa9f8d5a89159fc92] =   70; 
        allocations[0xe2abdae2980a1447f445cb962f9c0bef1b63ee13] =   70;
        allocations[0x729a5c0232712caaf365fdd03c39cb361bd41b1c] =   70;
        allocations[0x12fbd8fef4903f62e30dd79ac7f439f573e02697] =   70;
        allocations[0x657013005e5cfaf76f75d03b465ce085d402469a] =   42; 
        allocations[0xd0af9f75ea618163944585bf56aca98204d0ab66] =   25; 
    }

    
    
    function unlock() external {
        if (now < unlockedat) throw;

        
        if (tokenscreated == 0)
            tokenscreated = gnt.balanceof(this);

        var allocation = allocations[msg.sender];
        allocations[msg.sender] = 0;
        var totransfer = tokenscreated * allocation / totalallocations;

        
        if (!gnt.transfer(msg.sender, totransfer)) throw;
    }
}