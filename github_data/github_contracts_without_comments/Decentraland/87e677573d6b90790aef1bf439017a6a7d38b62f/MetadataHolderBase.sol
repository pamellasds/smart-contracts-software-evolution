pragma solidity ^0.4.22;


contract metadataholderbase {
  bytes4 constant public get_metadata = bytes4(keccak256());
  bytes4 constant public erc165_support = bytes4(keccak256());

  function supportsinterface(bytes4 _interfaceid) external pure returns (bool) {
    return ((_interfaceid == erc165_support) ||
      (_interfaceid == get_metadata));
  }
}
