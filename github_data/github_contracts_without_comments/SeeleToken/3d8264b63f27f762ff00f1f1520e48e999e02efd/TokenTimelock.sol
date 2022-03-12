pragma solidity ^0.4.4;


import ;
import ;


contract tokentimelock {
  using safeerc20 for erc20basic;

  
  erc20basic public token;

  
  address public beneficiary;

  
  uint public releasetime;

  function tokentimelock(erc20basic _token, address _beneficiary, uint _releasetime) public {
    require(_releasetime > now);
    token = _token;
    beneficiary = _beneficiary;
    releasetime = _releasetime;
  }

  
  function release() public {
    require(now >= releasetime);

    uint256 amount = token.balanceof(this);
    require(amount > 0);

    token.safetransfer(beneficiary, amount);
  }
}
