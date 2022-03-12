pragma solidity ^0.4.22;

import ;

contract estateregistrytest is estateregistry {
  constructor(
    string _name,
    string _symbol,
    address _registry
  )
    public
  {
    estateregistry.initialize(_name, _symbol, _registry);
  }

  function mintestate(address to, string metadata) public returns (uint256) {
    return _mintestate(to, metadata);
  }

  function getmetadatainterfaceid() public pure returns (bytes4) {
    return interfaceid_getmetadata;
  }
}
