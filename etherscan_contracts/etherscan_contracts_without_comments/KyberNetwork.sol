

pragma solidity ^0.4.13;

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
}

contract ownable {
  address public owner;


  
  function ownable() {
    owner = msg.sender;
  }


  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferownership(address newowner) onlyowner {
    if (newowner != address(0)) {
      owner = newowner;
    }
  }

}



contract erc20basic {
  uint256 public totalsupply;
  function balanceof(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  
  
  event transfer(address indexed _from, address indexed _to, uint _value);
  
}

contract basictoken is erc20basic {
  using safemath for uint256;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceof(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract erc20 is erc20basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferfrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  
  
  event approval(address indexed _owner, address indexed _spender, uint _value);
  
}

contract standardtoken is erc20, basictoken {

  mapping (address => mapping (address => uint256)) allowed;


  
  function transferfrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    
    

    
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    
    allowed[_from][msg.sender] = _allowance.sub(_value);
    transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) returns (bool) {

    
    
    
    
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract kybernetworkcrystal is standardtoken, ownable {
    string  public  constant name = ;
    string  public  constant symbol = ;
    uint    public  constant decimals = 18;

    uint    public  salestarttime;
    uint    public  saleendtime;

    address public  tokensalecontract;

    modifier onlywhentransferenabled() {
        if( now <= saleendtime && now >= salestarttime ) {
            require( msg.sender == tokensalecontract );
        }
        _;
    }

    modifier validdestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }

    function kybernetworkcrystal( uint tokentotalamount, uint starttime, uint endtime, address admin ) {
        
        balances[msg.sender] = tokentotalamount;
        totalsupply = tokentotalamount;
        transfer(address(0x0), msg.sender, tokentotalamount);

        salestarttime = starttime;
        saleendtime = endtime;

        tokensalecontract = msg.sender;
        transferownership(admin); 
    }

    function transfer(address _to, uint _value)
        onlywhentransferenabled
        validdestination(_to)
        returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferfrom(address _from, address _to, uint _value)
        onlywhentransferenabled
        validdestination(_to)
        returns (bool) {
        return super.transferfrom(_from, _to, _value);
    }

    event burn(address indexed _burner, uint _value);

    function burn(uint _value) onlywhentransferenabled
        returns (bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalsupply = totalsupply.sub(_value);
        burn(msg.sender, _value);
        transfer(msg.sender, address(0x0), _value);
        return true;
    }

    
    function burnfrom(address _from, uint256 _value) onlywhentransferenabled
        returns (bool) {
        assert( transferfrom( _from, msg.sender, _value ) );
        return burn(_value);
    }

    function emergencyerc20drain( erc20 token, uint amount ) onlyowner {
        token.transfer( owner, amount );
    }
}