

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






contract seeletoken is pausabletoken {
    using safemath for uint;

    
    string public constant name = ;
    string public constant symbol = ;
    uint public constant decimals = 18;

    
    uint public currentsupply;

    
    
    address public minter; 

    
    mapping (address => uint) public lockedbalances;

    
    bool public claimedflag;  

    
    modifier onlyminter {
        require(msg.sender == minter);
        _;
    }

    modifier canclaimed {
        require(claimedflag == true);
        _;
    }

    modifier maxtokenamountnotreached (uint amount){
        require(currentsupply.add(amount) <= totalsupply);
        _;
    }

    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    
    function seeletoken(address _minter, address _admin, uint _maxtotalsupply) 
        public 
        validaddress(_admin)
        validaddress(_minter)
        {
        minter = _minter;
        totalsupply = _maxtotalsupply;
        claimedflag = false;
        paused = true;
        transferownership(_admin);
    }

    

    function mint(address receipent, uint amount, bool islock)
        external
        onlyminter
        maxtokenamountnotreached(amount)
        returns (bool)
    {
        if (islock ) {
            lockedbalances[receipent] = lockedbalances[receipent].add(amount);
        } else {
            balances[receipent] = balances[receipent].add(amount);
        }
        currentsupply = currentsupply.add(amount);
        return true;
    }


    function setclaimedflag(bool flag) 
        public
        onlyowner 
    {
        claimedflag = flag;
    }

     

    
    function claimtokens(address[] receipents)
        external
        onlyowner
        canclaimed
    {        
        for (uint i = 0; i < receipents.length; i++) {
            address receipent = receipents[i];
            balances[receipent] = balances[receipent].add(lockedbalances[receipent]);
            lockedbalances[receipent] = 0;
        }
    }

    function airdrop(address[] receipents, uint[] tokens)
        external
    {        
        for (uint i = 0; i < receipents.length; i++) {
            address receipent = receipents[i];
            uint token = tokens[i];
            if(balances[msg.sender] >= token ){
                balances[msg.sender] = balances[msg.sender].sub(token);
                balances[receipent] = balances[receipent].add(token);
            }
        }
    }
}