pragma solidity ^0.4.18;

import ;

contract landregistrytest is landregistry {
  function safetransferfromtoestate(address from, address to, uint256 assetid, uint256 estateid) external {
    _dotransferfrom(from, to, assetid, tobytes(estateid), true);
  }

  function existsproxy(int x, int y) view public returns (bool) {
    return _exists(_encodetokenid(x, y));
  }

  function isdeploymentauthorized(address beneficiary) view public returns (bool) {
    return authorizeddeploy[beneficiary];
  }
}
