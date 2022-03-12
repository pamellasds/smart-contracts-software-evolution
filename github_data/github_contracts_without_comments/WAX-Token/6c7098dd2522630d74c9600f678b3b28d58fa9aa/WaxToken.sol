pragma solidity ^0.4.13;


import ;
import ;



contract waxtoken is standardtoken, pausable {

  string public constant name = ;                          
  string public constant symbol = ;                                 
  uint8 public constant decimals = 8;                                  
  uint256 public constant initial_supply = 1000000000 * 10**uint256(decimals);    

  
  function waxtoken() {
    totalsupply = initial_supply;                               
    balances[msg.sender] = initial_supply;                      
    contractaddress = this;
    transfer(0x0, msg.sender, initial_supply);
  }

  
  function transfer(address _to, uint256 _value) whennotpaused returns (bool) {
    require(_to != address(0));
    require(_to != contractaddress);
    return super.transfer(_to, _value);
  }

  
  function transferfrom(address _from, address _to, uint256 _value) whennotpaused returns (bool) {
    require(_to != address(0));
    require(_to != contractaddress);
    return super.transferfrom(_from, _to, _value);
  }

  
  function approve(address _spender, uint256 _value) whennotpaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function() payable {
      revert();
  }

}
