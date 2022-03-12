pragma solidity ^0.4.24;

import ;
import ;
import ;
import ;


contract curvebondedreputationtoken is reputationtoken {
  using safemath for uint256;

  erc20basic public backingtoken;
  
  function getreputation() public returns (uint256) {
    return totalsupply_;
  }

  function long(uint256 _amount) public returns (bool);

  function short(uint256 _amount) public returns (bool);

}
