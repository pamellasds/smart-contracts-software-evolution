pragma solidity ^0.4.18;



contract erc20basic {
  uint256 public totalsupply;
  function balanceof(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity ^0.4.18;

import ;
import ;



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
pragma solidity ^0.4.18;



import ;



contract pausable is ownable {
  event pausepublic(bool newstate);
  event pauseowneradmin(bool newstate);

  bool public pausedpublic = true;
  bool public pausedowneradmin = false;

  address public admin;

  
  modifier whennotpaused() {
    if(pausedpublic) {
      if(!pausedowneradmin) {
        require(msg.sender == admin || msg.sender == owner);
      } else {
        revert();
      }
    }
    _;
  }

  
  function pause(bool newpausedpublic, bool newpausedowneradmin) onlyowner public {
    require(!(newpausedpublic == false && newpausedowneradmin == true));

    pausedpublic = newpausedpublic;
    pausedowneradmin = newpausedowneradmin;

    pausepublic(newpausedpublic);
    pauseowneradmin(newpausedowneradmin);
  }
}
pragma solidity ^0.4.18;


import ;
import ;



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
pragma solidity ^0.4.18;



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
pragma solidity ^0.4.18;

import ;

contract zilliqatoken is pausabletoken {
    string  public  constant name = ;
    string  public  constant symbol = ;
    uint8   public  constant decimals = 12;

    modifier validdestination( address to )
    {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function zilliqatoken( address _admin, uint _totaltokenamount ) 
    {
        
        admin = _admin;

        
        totalsupply = _totaltokenamount;
        balances[msg.sender] = _totaltokenamount;
        transfer(address(0x0), msg.sender, _totaltokenamount);
    }

    function transfer(address _to, uint _value) validdestination(_to) returns (bool) 
    {
        return super.transfer(_to, _value);
    }

    function transferfrom(address _from, address _to, uint _value) validdestination(_to) returns (bool) 
    {
        return super.transferfrom(_from, _to, _value);
    }

    event burn(address indexed _burner, uint _value);

    function burn(uint _value) returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalsupply = totalsupply.sub(_value);
        burn(msg.sender, _value);
        transfer(msg.sender, address(0x0), _value);
        return true;
    }

    
    function burnfrom(address _from, uint256 _value) returns (bool) 
    {
        assert( transferfrom( _from, msg.sender, _value ) );
        return burn(_value);
    }

    function emergencyerc20drain( erc20 token, uint amount ) onlyowner {
        
        token.transfer( owner, amount );
    }

    event admintransferred(address indexed previousadmin, address indexed newadmin);

    function changeadmin(address newadmin) onlyowner {
        
        admintransferred(admin, newadmin);
        admin = newadmin;
    }
}
pragma solidity ^0.4.18;


import ;
import ;



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