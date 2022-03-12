pragma solidity ^0.4.15;

import ;

import ;

contract burnabletoken {
  function burn(uint);
  function transferfrom(address, address, uint256);
}

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

  function buy(uint x, uint y, string data, address _beneficiary, address _from) public {
    address from = _from;
    if (from == 0) {
      from = msg.sender;
    }
    address beneficiary = _beneficiary;
    if (beneficiary == 0) {
      beneficiary = msg.sender;
    }
    if (exists(x, y)) {
      revert();
    }
    if (!exists(x1, y) && !exists(x+1, y) && !exists(x, y1) && !exists(x, y+1)) {
      revert();
    }
    uint cost = 1000 * 1e18;
    token.transferfrom(from, this, cost);
    token.burn(cost);
    return land.assignnewparcel(beneficiary, buildtokenid(x, y), data);
  }
}
