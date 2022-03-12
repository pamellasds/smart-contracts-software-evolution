pragma solidity ^0.4.23;

import ;
import ;


contract landstorage {
  mapping (address => uint) public latestping;

  uint256 constant clearlow = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 constant clearhigh = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  uint256 constant factor = 0x100000000000000000000000000000000;

  mapping (address => bool) internal _deprecated_authorizeddeploy;

  mapping (uint256 => address) public updateoperator;

  iestateregistry public estateregistry;

  mapping (address => bool) public authorizeddeploy;

  mapping(address => mapping(address => bool)) public updatemanager;

  
  iminimetoken public landbalance;

  
  mapping(address => bool) public registeredbalance;
}
