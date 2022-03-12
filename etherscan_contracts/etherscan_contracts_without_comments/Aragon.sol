

pragma solidity ^0.4.8;

contract erc20 {
  function totalsupply() constant returns (uint);
  function balanceof(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferfrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event transfer(address indexed from, address indexed to, uint value);
  event approval(address indexed owner, address indexed spender, uint value);
}


contract safemath {
  function safemul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safediv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safesub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a  b;
  }

  function safeadd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
contract approveandcallreceiver {
    function receiveapproval(address _from, uint256 _amount, address _token, bytes _data);
}

contract controlled {
    
    
    modifier onlycontroller { if (msg.sender != controller) throw; _; }

    address public controller;

    function controlled() { controller = msg.sender;}

    
    
    function changecontroller(address _newcontroller) onlycontroller {
        controller = _newcontroller;
    }
}
contract abstractsale {
  function salefinalized() constant returns (bool);
}

contract salewallet {
  
  address public multisig;
  uint public finalblock;
  abstractsale public tokensale;

  
  
  
  function salewallet(address _multisig, uint _finalblock, address _tokensale) {
    multisig = _multisig;
    finalblock = _finalblock;
    tokensale = abstractsale(_tokensale);
  }

  
  function () public payable {}

  
  function withdraw() public {
    if (msg.sender != multisig) throw;                       
    if (block.number > finalblock) return dowithdraw();      
    if (tokensale.salefinalized()) return dowithdraw();      
  }

  function dowithdraw() internal {
    if (!multisig.send(this.balance)) throw;
  }
}

contract controller {
    
    
    
    function proxypayment(address _owner) payable returns(bool);

    
    
    
    
    
    
    function ontransfer(address _from, address _to, uint _amount) returns(bool);

    
    
    
    
    
    
    function onapprove(address _owner, address _spender, uint _amount)
        returns(bool);
}

contract anplaceholder is controller {
  address public sale;
  ant public token;

  function anplaceholder(address _sale, address _ant) {
    sale = _sale;
    token = ant(_ant);
  }

  function changecontroller(address network) public {
    if (msg.sender != sale) throw;
    token.changecontroller(network);
    suicide(network);
  }

  
  function proxypayment(address _owner) payable public returns (bool) {
    throw;
    return false;
  }

  function ontransfer(address _from, address _to, uint _amount) public returns (bool) {
    return true;
  }

  function onapprove(address _owner, address _spender, uint _amount) public returns (bool) {
    return true;
  }
}




contract minimetoken is erc20, controlled {
    string public name;                
    uint8 public decimals;             
    string public symbol;              
    string public version = ; 


    
    
    
    struct  checkpoint {

        
        uint128 fromblock;

        
        uint128 value;
    }

    
    
    minimetoken public parenttoken;

    
    
    uint public parentsnapshotblock;

    
    uint public creationblock;

    
    
    
    mapping (address => checkpoint[]) balances;

    
    mapping (address => mapping (address => uint256)) allowed;

    
    checkpoint[] totalsupplyhistory;

    
    bool public transfersenabled;

    
    minimetokenfactory public tokenfactory;





    
    
    
    
    
    
    
    
    
    
    
    
    
    function minimetoken(
        address _tokenfactory,
        address _parenttoken,
        uint _parentsnapshotblock,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol,
        bool _transfersenabled
    ) {
        tokenfactory = minimetokenfactory(_tokenfactory);
        name = _tokenname;                                 
        decimals = _decimalunits;                          
        symbol = _tokensymbol;                             
        parenttoken = minimetoken(_parenttoken);
        parentsnapshotblock = _parentsnapshotblock;
        transfersenabled = _transfersenabled;
        creationblock = block.number;
    }






    
    
    
    
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (!transfersenabled) throw;
        return dotransfer(msg.sender, _to, _amount);
    }

    
    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {

        
        
        
        
        if (msg.sender != controller) {
            if (!transfersenabled) throw;

            
            if (allowed[_from][msg.sender] < _amount) throw;
            allowed[_from][msg.sender] = _amount;
        }
        return dotransfer(_from, _to, _amount);
    }

    
    
    
    
    
    
    function dotransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {

           if (_amount == 0) {
               return true;
           }

           
           if ((_to == 0) || (_to == address(this))) throw;

           
           
           var previousbalancefrom = balanceofat(_from, block.number);
           if (previousbalancefrom < _amount) {
               throw;
           }

           
           if (iscontract(controller)) {
               if (!controller(controller).ontransfer(_from, _to, _amount)) throw;
           }

           
           
           updatevalueatnow(balances[_from], previousbalancefrom  _amount);

           
           
           var previousbalanceto = balanceofat(_to, block.number);
           if (previousbalanceto + _amount < previousbalanceto) throw; 
           updatevalueatnow(balances[_to], previousbalanceto + _amount);

           
           transfer(_from, _to, _amount);

           return true;
    }

    
    
    function balanceof(address _owner) constant returns (uint256 balance) {
        return balanceofat(_owner, block.number);
    }

    
    
    
    
    
    
    function approve(address _spender, uint256 _amount) returns (bool success) {
        if (!transfersenabled) throw;

        
        
        
        
        if ((_amount!=0) && (allowed[msg.sender][_spender] !=0)) throw;

        
        if (iscontract(controller)) {
            if (!controller(controller).onapprove(msg.sender, _spender, _amount))
                throw;
        }

        allowed[msg.sender][_spender] = _amount;
        approval(msg.sender, _spender, _amount);
        return true;
    }

    
    
    
    
    
    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    
    
    
    
    
    
    function approveandcall(address _spender, uint256 _amount, bytes _extradata
    ) returns (bool success) {
        approve(_spender, _amount);

        
        
        
        
        
        
        approveandcallreceiver(_spender).receiveapproval(
           msg.sender,
           _amount,
           this,
           _extradata
        );
        return true;
    }

    
    
    function totalsupply() constant returns (uint) {
        return totalsupplyat(block.number);
    }






    
    
    
    
    function balanceofat(address _owner, uint _blocknumber) constant
        returns (uint) {

        
        
        
        
        
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromblock > _blocknumber)) {
            if (address(parenttoken) != 0) {
                return parenttoken.balanceofat(_owner, min(_blocknumber, parentsnapshotblock));
            } else {
                
                return 0;
            }

        
        } else {
            return getvalueat(balances[_owner], _blocknumber);
        }
    }

    
    
    
    function totalsupplyat(uint _blocknumber) constant returns(uint) {

        
        
        
        
        
        if ((totalsupplyhistory.length == 0)
            || (totalsupplyhistory[0].fromblock > _blocknumber)) {
            if (address(parenttoken) != 0) {
                return parenttoken.totalsupplyat(min(_blocknumber, parentsnapshotblock));
            } else {
                return 0;
            }

        
        } else {
            return getvalueat(totalsupplyhistory, _blocknumber);
        }
    }

    function min(uint a, uint b) internal returns (uint) {
      return a < b ? a : b;
    }





    
    
    
    
    
    
    
    
    
    
    function createclonetoken(
        string _clonetokenname,
        uint8 _clonedecimalunits,
        string _clonetokensymbol,
        uint _snapshotblock,
        bool _transfersenabled
        ) returns(address) {
        if (_snapshotblock > block.number) _snapshotblock = block.number;
        minimetoken clonetoken = tokenfactory.createclonetoken(
            this,
            _snapshotblock,
            _clonetokenname,
            _clonedecimalunits,
            _clonetokensymbol,
            _transfersenabled
            );

        clonetoken.changecontroller(msg.sender);

        
        newclonetoken(address(clonetoken), _snapshotblock);
        return address(clonetoken);
    }





    
    
    
    
    function generatetokens(address _owner, uint _amount
    ) onlycontroller returns (bool) {
        uint curtotalsupply = getvalueat(totalsupplyhistory, block.number);
        if (curtotalsupply + _amount < curtotalsupply) throw; 
        updatevalueatnow(totalsupplyhistory, curtotalsupply + _amount);
        var previousbalanceto = balanceof(_owner);
        if (previousbalanceto + _amount < previousbalanceto) throw; 
        updatevalueatnow(balances[_owner], previousbalanceto + _amount);
        transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroytokens(address _owner, uint _amount
    ) onlycontroller returns (bool) {
        uint curtotalsupply = getvalueat(totalsupplyhistory, block.number);
        if (curtotalsupply < _amount) throw;
        updatevalueatnow(totalsupplyhistory, curtotalsupply  _amount);
        var previousbalancefrom = balanceof(_owner);
        if (previousbalancefrom < _amount) throw;
        updatevalueatnow(balances[_owner], previousbalancefrom  _amount);
        transfer(_owner, 0, _amount);
        return true;
    }






    
    
    function enabletransfers(bool _transfersenabled) onlycontroller {
        transfersenabled = _transfersenabled;
    }





    
    
    
    
    function getvalueat(checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        
        if (_block >= checkpoints[checkpoints.length1].fromblock)
            return checkpoints[checkpoints.length1].value;
        if (_block < checkpoints[0].fromblock) return 0;

        
        uint min = 0;
        uint max = checkpoints.length1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromblock<=_block) {
                min = mid;
            } else {
                max = mid1;
            }
        }
        return checkpoints[min].value;
    }

    
    
    
    
    function updatevalueatnow(checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length 1].fromblock < block.number)) {
               checkpoint newcheckpoint = checkpoints[ checkpoints.length++ ];
               newcheckpoint.fromblock =  uint128(block.number);
               newcheckpoint.value = uint128(_value);
           } else {
               checkpoint oldcheckpoint = checkpoints[checkpoints.length1];
               oldcheckpoint.value = uint128(_value);
           }
    }

    
    
    
    function iscontract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    
    
    
    function ()  payable {
        if (iscontract(controller)) {
            if (! controller(controller).proxypayment.value(msg.value)(msg.sender))
                throw;
        } else {
            throw;
        }
    }





    event newclonetoken(address indexed _clonetoken, uint _snapshotblock);
}









contract minimetokenfactory {

    
    
    
    
    
    
    
    
    
    
    function createclonetoken(
        address _parenttoken,
        uint _snapshotblock,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol,
        bool _transfersenabled
    ) returns (minimetoken) {
        minimetoken newtoken = new minimetoken(
            this,
            _parenttoken,
            _snapshotblock,
            _tokenname,
            _decimalunits,
            _tokensymbol,
            _transfersenabled
            );

        newtoken.changecontroller(msg.sender);
        return newtoken;
    }
}












contract minimeirrevocablevestedtoken is minimetoken, safemath {
  
  struct tokengrant {
    address granter;
    uint256 value;
    uint64 cliff;
    uint64 vesting;
    uint64 start;
  }

  event newtokengrant(address indexed from, address indexed to, uint256 value, uint64 start, uint64 cliff, uint64 vesting);

  mapping (address => tokengrant[]) public grants;

  mapping (address => bool) cancreategrants;
  address vestingwhitelister;

  modifier cantransfer(address _sender, uint _value) {
    if (_value > spendablebalanceof(_sender)) throw;
    _;
  }

  modifier onlyvestingwhitelister {
    if (msg.sender != vestingwhitelister) throw;
    _;
  }

  function minimeirrevocablevestedtoken (
      address _tokenfactory,
      address _parenttoken,
      uint _parentsnapshotblock,
      string _tokenname,
      uint8 _decimalunits,
      string _tokensymbol,
      bool _transfersenabled
  ) minimetoken(_tokenfactory, _parenttoken, _parentsnapshotblock, _tokenname, _decimalunits, _tokensymbol, _transfersenabled) {
    vestingwhitelister = msg.sender;
    dosetcancreategrants(vestingwhitelister, true);
  }

  
  function transfer(address _to, uint _value)
           cantransfer(msg.sender, _value)
           public
           returns (bool success) {
    return super.transfer(_to, _value);
  }

  function transferfrom(address _from, address _to, uint _value)
           cantransfer(_from, _value)
           public
           returns (bool success) {
    return super.transferfrom(_from, _to, _value);
  }

  function spendablebalanceof(address _holder) constant public returns (uint) {
    return transferabletokens(_holder, uint64(now));
  }

  function grantvestedtokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting) public {

    
    if (_cliff < _start) throw;
    if (_vesting < _start) throw;
    if (_vesting < _cliff) throw;

    if (!cancreategrants[msg.sender]) throw;
    if (tokengrantscount(_to) > 20) throw;   

    tokengrant memory grant = tokengrant(msg.sender, _value, _cliff, _vesting, _start);
    grants[_to].push(grant);

    if (!transfer(_to, _value)) throw;

    newtokengrant(msg.sender, _to, _value, _cliff, _vesting, _start);
  }

  function setcancreategrants(address _addr, bool _allowed)
           onlyvestingwhitelister public {
    dosetcancreategrants(_addr, _allowed);
  }

  function dosetcancreategrants(address _addr, bool _allowed)
           internal {
    cancreategrants[_addr] = _allowed;
  }

  function changevestingwhitelister(address _newwhitelister) onlyvestingwhitelister public {
    dosetcancreategrants(vestingwhitelister, false);
    vestingwhitelister = _newwhitelister;
    dosetcancreategrants(vestingwhitelister, true);
  }

  
  function revoketokengrant(address _holder, uint _grantid) public {
    throw;
  }

  
    return grants[_holder].length;
  }

  function tokengrant(address _holder, uint _grantid) constant public returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting) {
    tokengrant grant = grants[_holder][_grantid];

    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;

    vested = vestedtokens(grant, uint64(now));
  }

  function vestedtokens(tokengrant grant, uint64 time) internal constant returns (uint256) {
    return calculatevestedtokens(
      grant.value,
      uint256(time),
      uint256(grant.start),
      uint256(grant.cliff),
      uint256(grant.vesting)
    );
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  function calculatevestedtokens(
    uint256 tokens,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) internal constant returns (uint256)
    {

    
    if (time < cliff) return 0;
    if (time >= vesting) return tokens;

    
    
    

    
    uint256 vestedtokens = safediv(
                                  safemul(
                                    tokens,
                                    safesub(time, start)
                                    ),
                                  safesub(vesting, start)
                                  );

    return vestedtokens;
  }

  function nonvestedtokens(tokengrant grant, uint64 time) internal constant returns (uint256) {
    
    
    return safesub(grant.value, vestedtokens(grant, time));
  }

  
  
  function lasttokenistransferabledate(address holder) constant public returns (uint64 date) {
    date = uint64(now);
    uint256 grantindex = tokengrantscount(holder);
    for (uint256 i = 0; i < grantindex; i++) {
      date = max64(grants[holder][i].vesting, date);
    }
    return date;
  }

  
  function transferabletokens(address holder, uint64 time) constant public returns (uint256) {
    uint256 grantindex = tokengrantscount(holder);

    if (grantindex == 0) return balanceof(holder); 

    
    uint256 nonvested = 0;
    for (uint256 i = 0; i < grantindex; i++) {
      nonvested = safeadd(nonvested, nonvestedtokens(grants[holder][i], time));
    }

    
    return safesub(balanceof(holder), nonvested);
  }
}



contract ant is minimeirrevocablevestedtoken {
  
  function ant(
    address _tokenfactory
  ) minimeirrevocablevestedtoken(
    _tokenfactory,
    0x0,                    
    0,                      
    , 
    18,                     
    ,                  
    true                    
    ) {}
}