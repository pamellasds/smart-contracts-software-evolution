pragma solidity ^0.4.13;

import ;
import ;



contract waxtoken is standardtoken, pausable {

  string public constant name = ;                              
  string public constant symbol = ;                                  
  uint8 public constant decimals = 8;                                     
  uint256 public constant initial_supply = 185e6 * 10**uint256(decimals); 

  
  modifier rejecttokenstocontract(address _to) {
    require(_to != address(this));
    _;
  }

  
  function waxtoken() {
    totalsupply = initial_supply;                               
    balances[msg.sender] = initial_supply;                      
    transfer(0x0, msg.sender, initial_supply);
  }

  
  function transfer(address _to, uint256 _value) rejecttokenstocontract(_to) public whennotpaused returns (bool) {
    return super.transfer(_to, _value);
  }

  
  function transferfrom(address _from, address _to, uint256 _value) rejecttokenstocontract(_to) public whennotpaused returns (bool) {
    return super.transferfrom(_from, _to, _value);
  }

  
  function approve(address _spender, uint256 _value) public whennotpaused returns (bool) {
    return super.approve(_spender, _value);
  }

  
  function increaseapproval (address _spender, uint _addedvalue) public whennotpaused returns (bool success) {
    return super.increaseapproval(_spender, _addedvalue);
  }

  
  function decreaseapproval (address _spender, uint _subtractedvalue) public whennotpaused returns (bool success) {
    return super.decreaseapproval(_spender, _subtractedvalue);
  }

}
