pragma solidity ^0.4.18;

contract assetregistrystorage {

  string internal _name;
  string internal _symbol;
  string internal _description;

  
  uint256 internal _count;

  
  mapping(address => uint256[]) internal _assetsof;

  
  mapping(uint256 => address) internal _holderof;

  
  mapping(uint256 => uint256) internal _indexofasset;

  
  mapping(uint256 => string) internal _assetdata;

  
  mapping(address => mapping(address => bool)) internal _operators;

  
  bool internal _reentrancy;
}
