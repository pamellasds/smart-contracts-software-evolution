pragma solidity ^0.6.0;

import ;
import ;

contract token677 is erc20, erc677token {
  string private constant name = ;
  string private constant symbol = ;

  constructor(uint _initialbalance) erc20(name, symbol) public {
    _mint(msg.sender, _initialbalance);
  }
}
