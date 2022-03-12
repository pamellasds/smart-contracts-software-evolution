pragma solidity ^0.4.11;


import ;
import ;


contract linktoken is standardtoken, erc677token {

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
  public validrecipient(_to) returns (bool success)
  {
    return super.transferandcall(_to, _value, _data);
  }

  
  function transfer(address _to, uint _value)
  public validrecipient(_to) returns (bool success)
  {
    return super.transfer(_to, _value);
  }

  
  function approve(address _spender, uint256 _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }


  

  modifier validrecipient(address _recipient) {
    require(_recipient != address(0) && _recipient != address(this));
    _;
  }

}
