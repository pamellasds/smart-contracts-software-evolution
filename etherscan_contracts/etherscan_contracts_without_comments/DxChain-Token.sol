

pragma solidity ^0.4.23;



library safemath {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a  b;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract ownable {
  address public owner;


  event ownershiprenounced(address indexed previousowner);
  event ownershiptransferred(
    address indexed previousowner,
    address indexed newowner
  );


  
  constructor() public {
    owner = msg.sender;
  }

  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }

  
  function transferownership(address newowner) public onlyowner {
    require(newowner != address(0));
    emit ownershiptransferred(owner, newowner);
    owner = newowner;
  }

  
  function renounceownership() public onlyowner {
    emit ownershiprenounced(owner);
    owner = address(0);
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
    emit pause();
  }

  
  function unpause() onlyowner whenpaused public {
    paused = false;
    emit unpause();
  }
}



contract erc20basic {
  function totalsupply() public view returns (uint256);
  function balanceof(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}



contract erc20 is erc20basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferfrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


contract basictoken is erc20basic {
  using safemath for uint256;

  mapping(address => uint256) balances;

  uint256 totalsupply_;

  
  function totalsupply() public view returns (uint256) {
    return totalsupply_;
  }

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceof(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}



contract standardtoken is erc20, basictoken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  function transferfrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  
  function increaseapproval(
    address _spender,
    uint _addedvalue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedvalue));
    emit approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  
  function decreaseapproval(
    address _spender,
    uint _subtractedvalue
  )
    public
    returns (bool)
  {
    uint oldvalue = allowed[msg.sender][_spender];
    if (_subtractedvalue > oldvalue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldvalue.sub(_subtractedvalue);
    }
    emit approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}



contract pausabletoken is standardtoken, pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whennotpaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferfrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whennotpaused
    returns (bool)
  {
    return super.transferfrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whennotpaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseapproval(
    address _spender,
    uint _addedvalue
  )
    public
    whennotpaused
    returns (bool success)
  {
    return super.increaseapproval(_spender, _addedvalue);
  }

  function decreaseapproval(
    address _spender,
    uint _subtractedvalue
  )
    public
    whennotpaused
    returns (bool success)
  {
    return super.decreaseapproval(_spender, _subtractedvalue);
  }
}

contract dxtoken is pausabletoken {
    string public name = ;
    string public symbol = ;
    uint public decimals = 18;
    uint public initial_supply = 10**29;

    constructor() public {
        totalsupply_ = initial_supply;
        balances[msg.sender] = initial_supply;
    }
}