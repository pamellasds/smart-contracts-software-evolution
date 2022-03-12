pragma solidity ^0.6.0;

import ;
import ;

contract standardtokenmock is erc20, linkerc20 {

  constructor(address initialaccount, uint initialbalance) erc20(, ) public {
    _mint(initialaccount, initialbalance);
  }
}
