pragma solidity ^0.4.15;

import ;

contract burnabletoken {
  function transferfrom(address, address, uint) public returns (bool);
  function burn(uint) public;
}

import ;

contract simplelandsell is ownable {

  burnabletoken public token;
  land public land;

  function simplelandsell(address _token) {
    token = burnabletoken(_token);
    land = deployland();

    land.assignnewparcel(msg.sender, buildtokenid(0, 0), );
  }

  function deployland() internal returns (land) {
    return new land(this);
  }

  function exists(uint x, uint y) public constant returns (bool) {
    return land.exists(x, y);
  }

  function buildtokenid(uint x, uint y) public constant returns (uint256) {
    return land.buildtokenid(x, y);
  }

  event log(string info);

  function buy(uint x, uint y, string data) public {
    _buyland(x, y, data, msg.sender, msg.sender);
  }

  function _buyland(uint x, uint y, string metadata, address beneficiary, address fromaccount) internal {
    if (exists(x, y)) {
      revert();
    }
    if (!exists(x1, y) && !exists(x+1, y) && !exists(x, y1) && !exists(x, y+1)) {
      revert();
    }
    uint cost = 1e21;
    if (!token.transferfrom(fromaccount, this, cost)) {
      revert();
    }
    token.burn(cost);
    return land.assignnewparcel(beneficiary, buildtokenid(x, y), metadata);
  }
}
