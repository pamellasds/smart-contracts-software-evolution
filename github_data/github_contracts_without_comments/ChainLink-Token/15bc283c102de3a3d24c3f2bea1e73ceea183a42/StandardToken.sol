pragma solidity ^0.4.8;


import ;
import ;



contract standardtoken is erc20, basictoken {

  mapping (address => mapping (address => uint256)) allowed;


  
  function transferfrom(address _from, address _to, uint256 _value)
  public returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    
    

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    transfer(_from, _to, _value);
  }

  
  function approve(address _spender, uint256 _value)
  public returns (bool success) {

    
    
    
    
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
  }

  
  function allowance(address _owner, address _spender)
  constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}
