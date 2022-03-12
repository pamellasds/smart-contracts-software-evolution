pragma solidity ^0.4.15;

contract burnabletoken {
  function transferfrom(address, address, uint) public returns (bool);
  function burn(uint) public;
}

import ;

contract landsale {
  
  burnabletoken public token;
  landtoken public land;

  event log(string info);

  function exists(uint x, uint y) public constant returns (bool) {
    return land.exists(x, y);
  }

  function buildtokenid(uint x, uint y) public constant returns (uint256) {
    return land.buildtokenid(x, y);
  }

  function _isvalidland(uint256 _x, uint256 _y) internal returns (bool);

  function _buyland(uint x, uint y, string metadata, address beneficiary, address fromaccount, uint cost) internal {
    require(!exists(x, y));
    require(_isvalidland(x, y));

    
    if (!token.transferfrom(fromaccount, this, cost)) {
      revert();
    }
    token.burn(cost);

    land.assignnewparcel(beneficiary, buildtokenid(x, y), metadata);
  }
}
