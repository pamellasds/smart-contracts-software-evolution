pragma solidity ^0.4.1;

import ;

contract timelockedgntproxyaccount {

    address public owner;

    uint256 public availableafter;
    golemnetworktoken public gnt;

    

    modifier owneronly {
        if (msg.sender != owner) throw;
        _;
    }

    modifier notlocked {
    	if (now < availableafter) throw;
    	_;
    }

    

    function timelockedgntproxyaccount(uint256 _availableafter) {
        owner = msg.sender;
        availableafter = _availableafter;
    }

    function setgntcontract(address _gnt) owneronly external {
        gnt = golemnetworktoken(_gnt);
    }

    

    function transfer(address _to, uint256 _value) notlocked owneronly returns (bool success) {
        return gnt.transfer(_to, _value);
    }

    

    function migrate(uint256 _value) owneronly external {
        gnt.migrate(_value);
    }

    

    function() payable {
        throw;
    }
}


contract timelockedgolemfactoryproxyaccount is timelockedgntproxyaccount {

    

    function timelockedgolemfactoryproxyaccount(uint256 _availableafter) timelockedgntproxyaccount(_availableafter) {
    }
    
    
    
    modifier gntonly {
        if (msg.sender != address(gnt)) throw;
        _;
    }

    

    function setmigrationmaster(address _migrationmaster) owneronly external {
        gnt.setmigrationmaster(_migrationmaster);
    }
    

    function setmigrationagent(address _agent) owneronly external {
        gnt.setmigrationagent(_agent);
    }

    
    
    function() gntonly payable {
    }

    
    
    function withdraw() owneronly {
        if (!owner.send(this.balance)) throw;
    }
}
