pragma solidity ^0.4.18;

contract landstorage {

  mapping (address => uint) latestping;

  uint256 constant clearlow = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 constant clearhigh = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  uint256 constant factor = 0x100000000000000000000000000000000;

  mapping (address => bool) authorizeddeploy;

  mapping (uint256 => address) _updateauthorized;
}
