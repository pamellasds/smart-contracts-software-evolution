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
