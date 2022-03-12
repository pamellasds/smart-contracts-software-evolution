

pragma solidity ^0.4.11;



contract linkerc20basic {
  uint256 public totalsupply;
  function balanceof(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}



pragma solidity ^0.4.11;




contract linkerc20 is linkerc20basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferfrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.4.8;


contract erc677 is linkerc20 {
  function transferandcall(address to, uint value, bytes data) returns (bool success);

  event transfer(address indexed from, address indexed to, uint value, bytes data);
}



pragma solidity ^0.4.8;


contract erc677receiver {
  function ontokentransfer(address _sender, uint _value, bytes _data);
}



pragma solidity ^0.4.11;




contract erc677token is erc677 {

  
  function transferandcall(address _to, uint _value, bytes _data)
    public
    returns (bool success)
  {
    super.transfer(_to, _value);
    transfer(msg.sender, _to, _value, _data);
    if (iscontract(_to)) {
      contractfallback(_to, _value, _data);
    }
    return true;
  }


  

  function contractfallback(address _to, uint _value, bytes _data)
    private
  {
    erc677receiver receiver = erc677receiver(_to);
    receiver.ontokentransfer(msg.sender, _value, _data);
  }

  function iscontract(address _addr)
    private
    returns (bool hascode)
  {
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }

}



pragma solidity ^0.4.11;



library linksafemath {
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



pragma solidity ^0.4.11;





contract linkbasictoken is linkerc20basic {
  using linksafemath for uint256;

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



pragma solidity ^0.4.11;





contract linkstandardtoken is linkerc20, linkbasictoken {

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
    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
    
  function increaseapproval (address _spender, uint _addedvalue) 
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedvalue);
    approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseapproval (address _spender, uint _subtractedvalue) 
    returns (bool success) {
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



pragma solidity ^0.4.11;




contract linktoken is linkstandardtoken, erc677token {

  uint public constant totalsupply = 10**27;
  string public constant name = ;
  uint8 public constant decimals = 18;
  string public constant symbol = ;

  function linktoken()
    public
  {
    balances[msg.sender] = totalsupply;
  }

  
  function transferandcall(address _to, uint _value, bytes _data)
    public
    validrecipient(_to)
    returns (bool success)
  {
    return super.transferandcall(_to, _value, _data);
  }

  
  function transfer(address _to, uint _value)
    public
    validrecipient(_to)
    returns (bool success)
  {
    return super.transfer(_to, _value);
  }

  
  function approve(address _spender, uint256 _value)
    public
    validrecipient(_spender)
    returns (bool)
  {
    return super.approve(_spender,  _value);
  }

  
  function transferfrom(address _from, address _to, uint256 _value)
    public
    validrecipient(_to)
    returns (bool)
  {
    return super.transferfrom(_from, _to, _value);
  }


  

  modifier validrecipient(address _recipient) {
    require(_recipient != address(0) && _recipient != address(this));
    _;
  }

}
