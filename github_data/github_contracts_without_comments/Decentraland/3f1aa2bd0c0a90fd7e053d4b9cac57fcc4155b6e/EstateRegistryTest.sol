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

  function calculatexor(uint256 x, uint256 y) public pure returns (bytes32) {
    return keccak256(abi.encodepacked(x)) ^ keccak256(abi.encodepacked(y));
  }

  function compoundxor(bytes32 x, uint256 y) public pure returns (bytes32) {
    return x ^ keccak256(abi.encodepacked(y));
  }
}
