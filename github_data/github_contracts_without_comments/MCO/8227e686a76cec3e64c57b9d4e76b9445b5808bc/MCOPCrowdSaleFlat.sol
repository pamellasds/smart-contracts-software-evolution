pragma solidity ^0.4.18;




contract ownable {
  address public owner;


  event ownershiptransferred(address indexed previousowner, address indexed newowner);


  
  function ownable() public {
    owner = msg.sender;
  }


  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferownership(address newowner) public onlyowner {
    require(newowner != address(0));
    ownershiptransferred(owner, newowner);
    owner = newowner;
  }

}




contract pausable is ownable {
  event pause();
  event unpause();

  bool public paused = false;


  
  modifier whennotpaused() {
    require(!paused);
    _;
  }

  
  modifier whenpaused() {
    require(paused);
    _;
  }

  
  function pause() onlyowner whennotpaused public {
    paused = true;
    pause();
  }

  
  function unpause() onlyowner whenpaused public {
    paused = false;
    unpause();
  }
}




library safemath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a  b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}




contract erc20basic {
  uint256 public totalsupply;
  function balanceof(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}




contract basictoken is erc20basic {
  using safemath for uint256;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceof(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}




contract erc20 is erc20basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferfrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event approval(address indexed owner, address indexed spender, uint256 value);
}




contract standardtoken is erc20, basictoken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  function transferfrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  
  function increaseapproval(address _spender, uint _addedvalue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedvalue);
    approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  
  function decreaseapproval(address _spender, uint _subtractedvalue) public returns (bool) {
    uint oldvalue = allowed[msg.sender][_spender];
    if (_subtractedvalue > oldvalue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldvalue.sub(_subtractedvalue);
    }
    approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}





contract pausabletoken is standardtoken, pausable {

  function transfer(address _to, uint256 _value) public whennotpaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferfrom(address _from, address _to, uint256 _value) public whennotpaused returns (bool) {
    return super.transferfrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whennotpaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseapproval(address _spender, uint _addedvalue) public whennotpaused returns (bool success) {
    return super.increaseapproval(_spender, _addedvalue);
  }

  function decreaseapproval(address _spender, uint _subtractedvalue) public whennotpaused returns (bool success) {
    return super.decreaseapproval(_spender, _subtractedvalue);
  }
}






contract mcoptoken is pausabletoken {
    using safemath for uint;

    
    string public constant name = ;
    string public constant symbol = ;
    uint public constant decimals = 18;


    
    
    address public minter; 

    
    modifier onlyminter {
        assert(msg.sender == minter);
        _;
    }

    modifier islaterthan (uint x){
        assert(now > x);
        _;
    }
    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    
    function mcoptoken(address _minter, address _admin) 
        public 
        validaddress(_minter)
        validaddress(_admin)
    {
        minter = _minter;
        transferownership(_admin);
    }

    

    function mint(address receipent, uint amount)
        external
        onlyminter
        returns (bool)
    {
        balances[receipent] = balances[receipent].add(amount);
        totalsupply = totalsupply.add(amount);
        return true;
    }
}




library safeerc20 {
  function safetransfer(erc20basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safetransferfrom(erc20 token, address from, address to, uint256 value) internal {
    assert(token.transferfrom(from, to, value));
  }

  function safeapprove(erc20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}




contract tokentimelock {
  using safeerc20 for erc20basic;

  
  erc20basic public token;

  
  address public beneficiary;

  
  uint public releasetime;

  function tokentimelock(erc20basic _token, address _beneficiary, uint _releasetime) public {
    require(_releasetime > now);
    token = _token;
    beneficiary = _beneficiary;
    releasetime = _releasetime;
  }

  
  function release() public {
    require(now >= releasetime);

    uint256 amount = token.balanceof(this);
    require(amount > 0);

    token.safetransfer(beneficiary, amount);
  }
}






contract mcopcrowdsale is pausable {
    using safemath for uint;

    
    
    uint public constant mcop_total_supply = 5000000000 ether;

    
    uint public constant lock_time =  180 days;

    uint public constant lock_stake = 48;   
    uint public constant team_stake = 8;    
    uint public constant base_stake = 4;     
    uint public constant org_stake = 15;     
    uint public constant personal_stake = 25;

    
    uint public constant stake_multiplier = mcop_total_supply / 100;


    address public lockaddress;
    address public teamaddress;
    address public baseaddress;
    address public orgaddress;
    address public personaladdress;

    mcoptoken public mcoptoken; 

    
    tokentimelock public tokentimelock; 

    
    event lockaddress(address onwer);

    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function mcopcrowdsale( 
        address _lockaddress,
        address _teamaddress,
        address _baseaddress,
        address _orgaddress,
        address _personaladdress

        ) public 
        validaddress(_lockaddress) 
        validaddress(_teamaddress) 
        validaddress(_baseaddress) 
        validaddress(_orgaddress) 
        validaddress(_personaladdress) 
        {

        lockaddress = _lockaddress;
        teamaddress = _teamaddress;
        baseaddress = _baseaddress;
        orgaddress = _orgaddress;
        personaladdress = _personaladdress;

        mcoptoken = new mcoptoken(this, msg.sender);

        tokentimelock = new tokentimelock(mcoptoken, lockaddress, now + lock_time);

        mcoptoken.mint(tokentimelock, lock_stake * stake_multiplier);
        mcoptoken.mint(teamaddress, team_stake * stake_multiplier);
        mcoptoken.mint(baseaddress, base_stake * stake_multiplier);
        mcoptoken.mint(orgaddress, org_stake * stake_multiplier);  
        mcoptoken.mint(personaladdress, personal_stake * stake_multiplier); 
    
    }
    
    function() external payable {
        
    }
    
    function releaselocktoken() external {
        tokentimelock.release();
    }

    
    function withdrawbalance() external {
        uint256 balance = this.balance;
        owner.transfer(balance);
    }
}
