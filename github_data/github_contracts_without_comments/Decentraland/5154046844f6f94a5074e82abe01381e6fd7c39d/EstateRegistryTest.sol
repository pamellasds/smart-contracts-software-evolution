pragma solidity ^0.4.22;

import ;

contract estateregistrytest is estateregistry {
  constructor(
    string _name,
    string _symbol,
    address _registry
  )
    estateregistry(_name, _symbol, _registry)
    public
  {}

  function mintestate(address to, string metadata) public returns (uint256) {
    return _mintestate(to, metadata);
  }

  function pushlandid(uint256 estateid, uint256 landid) external {
    _pushlandid(estateid, landid);
  }
}
