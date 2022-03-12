


contract erc20 {
  uint public totalsupply;
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




contract standardtoken is erc20, safemath {

  
  event minted(address receiver, uint amount);

  
  mapping(address => uint) balances;

  
  mapping (address => mapping (address => uint)) allowed;

  
  function istoken() public constant returns (bool weare) {
    return true;
  }

  
  modifier onlypayloadsize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

  function transfer(address _to, uint _value) onlypayloadsize(2 * 32) returns (bool success) {
    balances[msg.sender] = safesub(balances[msg.sender], _value);
    balances[_to] = safeadd(balances[_to], _value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  function transferfrom(address _from, address _to, uint _value) returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeadd(balances[_to], _value);
    balances[_from] = safesub(balances[_from], _value);
    allowed[_from][msg.sender] = safesub(_allowance, _value);
    transfer(_from, _to, _value);
    return true;
  }

  function balanceof(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {

    
    
    
    
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}






contract upgradeagent {

  uint public originalsupply;

  
  function isupgradeagent() public constant returns (bool) {
    return true;
  }

  function upgradefrom(address _from, uint256 _value) public;

}



contract upgradeabletoken is standardtoken {

  
  address public upgrademaster;

  
  upgradeagent public upgradeagent;

  
  uint256 public totalupgraded;

  
  enum upgradestate {unknown, notallowed, waitingforagent, readytoupgrade, upgrading}

  
  event upgrade(address indexed _from, address indexed _to, uint256 _value);

  
  event upgradeagentset(address agent);

  
  function upgradeabletoken(address _upgrademaster) {
    upgrademaster = _upgrademaster;
  }

  
  function upgrade(uint256 value) public {

      upgradestate state = getupgradestate();
      if(!(state == upgradestate.readytoupgrade || state == upgradestate.upgrading)) {
        
        throw;
      }

      
      if (value == 0) throw;

      balances[msg.sender] = safesub(balances[msg.sender], value);

      
      totalsupply = safesub(totalsupply, value);
      totalupgraded = safeadd(totalupgraded, value);

      
      upgradeagent.upgradefrom(msg.sender, value);
      upgrade(msg.sender, upgradeagent, value);
  }

  
  function setupgradeagent(address agent) external {

      if(!canupgrade()) {
        
        throw;
      }

      if (agent == 0x0) throw;
      
      if (msg.sender != upgrademaster) throw;
      
      if (getupgradestate() == upgradestate.upgrading) throw;

      upgradeagent = upgradeagent(agent);

      
      if(!upgradeagent.isupgradeagent()) throw;
      
      if (upgradeagent.originalsupply() != totalsupply) throw;

      upgradeagentset(upgradeagent);
  }

  
  function getupgradestate() public constant returns(upgradestate) {
    if(!canupgrade()) return upgradestate.notallowed;
    else if(address(upgradeagent) == 0x00) return upgradestate.waitingforagent;
    else if(totalupgraded == 0) return upgradestate.readytoupgrade;
    else return upgradestate.upgrading;
  }

  
  function setupgrademaster(address master) public {
      if (master == 0x0) throw;
      if (msg.sender != upgrademaster) throw;
      upgrademaster = master;
  }

  
  function canupgrade() public constant returns(bool) {
     return true;
  }

}





contract ownable {
  address public owner;

  function ownable() {
    owner = msg.sender;
  }

  modifier onlyowner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function transferownership(address newowner) onlyowner {
    if (newowner != address(0)) {
      owner = newowner;
    }
  }

}





contract releasabletoken is erc20, ownable {

  
  address public releaseagent;

  
  bool public released = false;

  
  mapping (address => bool) public transferagents;

  
  modifier cantransfer(address _sender) {

    if(!released) {
        if(!transferagents[_sender]) {
            throw;
        }
    }

    _;
  }

  
  function setreleaseagent(address addr) onlyowner inreleasestate(false) public {

    
    releaseagent = addr;
  }

  
  function settransferagent(address addr, bool state) onlyowner inreleasestate(false) public {
    transferagents[addr] = state;
  }

  
  function releasetokentransfer() public onlyreleaseagent {
    released = true;
  }

  
  modifier inreleasestate(bool releasestate) {
    if(releasestate != released) {
        throw;
    }
    _;
  }

  
  modifier onlyreleaseagent() {
    if(msg.sender != releaseagent) {
        throw;
    }
    _;
  }

  function transfer(address _to, uint _value) cantransfer(msg.sender) returns (bool success) {
    
   return super.transfer(_to, _value);
  }

  function transferfrom(address _from, address _to, uint _value) cantransfer(_from) returns (bool success) {
    
    return super.transferfrom(_from, _to, _value);
  }

}






library safemathlib {

  function times(uint a, uint b) returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function minus(uint a, uint b) returns (uint) {
    assert(b <= a);
    return a  b;
  }

  function plus(uint a, uint b) returns (uint) {
    uint c = a + b;
    assert(c>=a);
    return c;
  }

  function assert(bool assertion) private {
    if (!assertion) throw;
  }
}




contract mintabletoken is standardtoken, ownable {

  using safemathlib for uint;

  bool public mintingfinished = false;

  
  mapping (address => bool) public mintagents;

  event mintingagentchanged(address addr, bool state  );

  
  function mint(address receiver, uint amount) onlymintagent canmint public {
    totalsupply = totalsupply.plus(amount);
    balances[receiver] = balances[receiver].plus(amount);

    
    
    transfer(0, receiver, amount);
  }

  
  function setmintagent(address addr, bool state) onlyowner canmint public {
    mintagents[addr] = state;
    mintingagentchanged(addr, state);
  }

  modifier onlymintagent() {
    
    if(!mintagents[msg.sender]) {
        throw;
    }
    _;
  }

  
  modifier canmint() {
    if(mintingfinished) throw;
    _;
  }
}




contract crowdsaletoken is releasabletoken, mintabletoken, upgradeabletoken {

  event updatedtokeninformation(string newname, string newsymbol);

  string public name;

  string public symbol;

  uint public decimals;

  
  function crowdsaletoken(string _name, string _symbol, uint _initialsupply, uint _decimals, bool _mintable)
    upgradeabletoken(msg.sender) {

    
    
    
    owner = msg.sender;

    name = _name;
    symbol = _symbol;

    totalsupply = _initialsupply;

    decimals = _decimals;

    
    balances[owner] = totalsupply;

    if(totalsupply > 0) {
      minted(owner, totalsupply);
    }

    
    if(!_mintable) {
      mintingfinished = true;
      if(totalsupply == 0) {
        throw; 
      }
    }
  }

  
  function releasetokentransfer() public onlyreleaseagent {
    mintingfinished = true;
    super.releasetokentransfer();
  }

  
  function canupgrade() public constant returns(bool) {
    return released && super.canupgrade();
  }

  
  function settokeninformation(string _name, string _symbol) onlyowner {
    name = _name;
    symbol = _symbol;

    updatedtokeninformation(name, symbol);
  }

}