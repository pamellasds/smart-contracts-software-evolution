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

  
  function exists(uint256 _x, uint256 _y) public constant returns (bool) {
    return land.exists(_x, _y);
  }

  function buildtokenid(uint256 _x, uint256 _y) public constant returns (uint256) {
    return land.buildtokenid(_x, _y);
  }

  function _isvalidland(uint256 _x, uint256 _y) internal returns (bool);

  function _buyland(uint256 _x, uint256 _y, string _metadata, address _beneficiary, address _fromaccount, uint256 _cost) internal {
    require(!exists(_x, _y));
    require(_isvalidland(_x, _y));

    
    if (!token.transferfrom(_fromaccount, this, _cost)) {
      revert();
    }
    token.burn(_cost);

    land.assignnewparcel(_beneficiary, buildtokenid(_x, _y), _metadata);
  }
}
