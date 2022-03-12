

pragma solidity ^0.4.11;

contract owned {

    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    function setowner(address _newowner) onlyowner {
        owner = _newowner;
    }
}


library safemath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a  b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function touint112(uint256 a) internal constant returns(uint112) {
    assert(uint112(a) == a);
    return uint112(a);
  }

  function touint120(uint256 a) internal constant returns(uint120) {
    assert(uint120(a) == a);
    return uint120(a);
  }

  function touint128(uint256 a) internal constant returns(uint128) {
    assert(uint128(a) == a);
    return uint128(a);
  }
}





contract token {
    
    
    
    function totalsupply() constant returns (uint256 supply);

    
    
    function balanceof(address _owner) constant returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success);

    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _value) returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);
}



contract ven is token, owned {
    using safemath for uint256;

    string public constant name    = ;  
    uint8 public constant decimals = 18;               
    string public constant symbol  = ;            

    
    struct supplies {
        
        
        uint128 total;
        uint128 rawtokens;
    }

    supplies supplies;

    
    struct account {
        
        
        uint112 balance;

        
        uint112 rawtokens;

        
        uint32 lastmintedtimestamp;
    }

    
    mapping(address => account) accounts;

    
    mapping(address => mapping(address => uint256)) allowed;

    
    uint256 bonusoffered;

    
    function ven() {
    }

    function totalsupply() constant returns (uint256 supply){
        return supplies.total;
    }

    
    function () {
        revert();
    }

    
    function issealed() constant returns (bool) {
        return owner == 0;
    }

    function lastmintedtimestamp(address _owner) constant returns(uint32) {
        return accounts[_owner].lastmintedtimestamp;
    }

    
    function claimbonus(address _owner) internal{      
        require(issealed());
        if (accounts[_owner].rawtokens != 0) {
            uint256 realbalance = balanceof(_owner);
            uint256 bonus = realbalance
                .sub(accounts[_owner].balance)
                .sub(accounts[_owner].rawtokens);

            accounts[_owner].balance = realbalance.touint112();
            accounts[_owner].rawtokens = 0;
            if(bonus > 0){
                transfer(this, _owner, bonus);
            }
        }
    }

    
    function balanceof(address _owner) constant returns (uint256 balance) {
        if (accounts[_owner].rawtokens == 0)
            return accounts[_owner].balance;

        if (bonusoffered > 0) {
            uint256 bonus = bonusoffered
                 .mul(accounts[_owner].rawtokens)
                 .div(supplies.rawtokens);

            return bonus.add(accounts[_owner].balance)
                    .add(accounts[_owner].rawtokens);
        }
        
        return uint256(accounts[_owner].balance)
            .add(accounts[_owner].rawtokens);
    }

    
    function transfer(address _to, uint256 _amount) returns (bool success) {
        require(issealed());

        
        claimbonus(msg.sender);
        claimbonus(_to);

        
        if (accounts[msg.sender].balance >= _amount
            && _amount > 0) {            
            accounts[msg.sender].balance = uint112(_amount);
            accounts[_to].balance = _amount.add(accounts[_to].balance).touint112();
            transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    
    
    
    
    
    
    function transferfrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        require(issealed());

        
        claimbonus(_from);
        claimbonus(_to);

        
        if (accounts[_from].balance >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {
            accounts[_from].balance = uint112(_amount);
            allowed[_from][msg.sender] = _amount;
            accounts[_to].balance = _amount.add(accounts[_to].balance).touint112();
            transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    
    
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        approval(msg.sender, _spender, _amount);
        return true;
    }

    
    function approveandcall(address _spender, uint256 _value, bytes _extradata) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);

        
        
        
        
        approvalreceiver(_spender).receiveapproval(msg.sender, _value, this, _extradata);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    function mint(address _owner, uint256 _amount, bool _israw, uint32 timestamp) onlyowner{
        if (_israw) {
            accounts[_owner].rawtokens = _amount.add(accounts[_owner].rawtokens).touint112();
            supplies.rawtokens = _amount.add(supplies.rawtokens).touint128();
        } else {
            accounts[_owner].balance = _amount.add(accounts[_owner].balance).touint112();
        }

        accounts[_owner].lastmintedtimestamp = timestamp;

        supplies.total = _amount.add(supplies.total).touint128();
        transfer(0, _owner, _amount);
    }
    
    
    function offerbonus(uint256 _bonus) onlyowner { 
        bonusoffered = bonusoffered.add(_bonus);
        supplies.total = _bonus.add(supplies.total).touint128();
        transfer(0, this, _bonus);
    }

    
    function seal() onlyowner {
        setowner(0);
    }
}

contract approvalreceiver {
    function receiveapproval(address _from, uint256 _value, address _tokencontract, bytes _extradata);
}



contract vensale is owned{

    
    
    
    
    
    
    enum stage {
        notcreated,
        created,
        initialized,
        early,
        normal,
        closed,
        finalized
    }

    using safemath for uint256;
    
    uint256 public constant totalsupply         = (10 ** 9) * (10 ** 18); 

    uint256 constant privatesupply              = totalsupply * 9 / 100;  
    uint256 constant commercialplan             = totalsupply * 23 / 100; 
    uint256 constant reservedforteam            = totalsupply * 5 / 100;  
    uint256 constant reservedforoperations      = totalsupply * 22 / 100; 

    
    uint256 public constant nonpublicsupply     = privatesupply + commercialplan + reservedforteam + reservedforoperations;
    
    uint256 public constant publicsupply = totalsupply  nonpublicsupply;


    uint256 public constant officiallimit = 64371825 * (10 ** 18);
    uint256 public constant channelslimit = publicsupply  officiallimit;

    
    struct soldout {
        uint16 placeholder; 

        
        
        uint120 official; 

        uint120 channels; 
    }

    soldout soldout;
    
    uint256 constant venpereth = 3500;  
    uint256 constant venperethearlystage = venpereth + venpereth * 15 / 100;  

    uint constant minbuyinterval = 30 minutes; 
    uint constant maxbuyethamount = 30 ether;
   
    ven ven; 

    address ethvault; 
    address venvault; 

    uint public constant starttime = 1503057600; 
    uint public constant endtime = 1504180800;   
    uint public constant earlystagelasts = 3 days; 

    bool initialized;
    bool finalized;

    function vensale() {
        soldout.placeholder = 1;
    }    

    
    
    function exchangerate() constant returns (uint256){
        if (stage() == stage.early) {
            return venperethearlystage;
        }
        if (stage() == stage.normal) {
            return venpereth;
        }
        return 0;
    }

    
    function blocktime() constant returns (uint32) {
        return uint32(block.timestamp);
    }

    
    
    function stage() constant returns (stage) { 
        if (finalized) {
            return stage.finalized;
        }

        if (!initialized) {
            
            return stage.created;
        }

        if (blocktime() < starttime) {
            
            return stage.initialized;
        }

        if (uint256(soldout.official).add(soldout.channels) >= publicsupply) {
            
            return stage.closed;
        }

        if (blocktime() < endtime) {
            
            if (blocktime() < starttime.add(earlystagelasts)) {
                
                return stage.early;
            }
            
            return stage.normal;
        }

        
        return stage.closed;
    }

    function iscontract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    
    function () payable {        
        buy();
    }

    
    function buy() payable {
        
        require(!iscontract(msg.sender));
        require(msg.value >= 0.01 ether);

        uint256 rate = exchangerate();
        
        require(rate > 0);
        
        require(blocktime() >= ven.lastmintedtimestamp(msg.sender) + minbuyinterval);

        uint256 requested;
        
        if (msg.value > maxbuyethamount) {
            requested = maxbuyethamount.mul(rate);
        } else {
            requested = msg.value.mul(rate);
        }

        uint256 remained = officiallimit.sub(soldout.official);
        if (requested > remained) {
            
            requested = remained;
        }

        uint256 ethcost = requested.div(rate);
        if (requested > 0) {
            ven.mint(msg.sender, requested, true, blocktime());
            
            ethvault.transfer(ethcost);

            soldout.official = requested.add(soldout.official).touint120();
            onsold(msg.sender, requested, ethcost);        
        }

        uint256 toreturn = msg.value.sub(ethcost);
        if(toreturn > 0) {
            
            msg.sender.transfer(toreturn);
        }        
    }

    
    function officialsold() constant returns (uint256) {
        return soldout.official;
    }

    
    function channelssold() constant returns (uint256) {
        return soldout.channels;
    } 

    
    function offertochannel(address _channelaccount, uint256 _venamount) onlyowner {
        stage stg = stage();
        
        require(stg == stage.early || stg == stage.normal || stg == stage.closed);

        soldout.channels = _venamount.add(soldout.channels).touint120();

        
        require(soldout.channels <= channelslimit);

        ven.mint(
            _channelaccount,
            _venamount,
            true,  
            blocktime()
            );

        onsold(_channelaccount, _venamount, 0);
    }

    
    
    
    
    function initialize(
        ven _ven,
        address _ethvault,
        address _venvault) onlyowner {
        require(stage() == stage.created);

        
        require(_ven.owner() == address(this));

        require(address(_ethvault) != 0);
        require(address(_venvault) != 0);      

        ven = _ven;
        
        ethvault = _ethvault;
        venvault = _venvault;    
        
        ven.mint(
            venvault,
            reservedforteam.add(reservedforoperations),
            false, 
            blocktime()
        );

        ven.mint(
            venvault,
            privatesupply.add(commercialplan),
            true, 
            blocktime()
        );

        initialized = true;
        oninitialized();
    }

    
    function finalize() onlyowner {
        
        require(stage() == stage.closed);       

        uint256 unsold = publicsupply.sub(soldout.official).sub(soldout.channels);

        if (unsold > 0) {
            
            ven.offerbonus(unsold);        
        }
        ven.seal();

        finalized = true;
        onfinalized();
    }

    event oninitialized();
    event onfinalized();

    event onsold(address indexed buyer, uint256 venamount, uint256 ethcost);
}