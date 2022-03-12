pragma solidity ^0.4.11;


import ;
import ;



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
