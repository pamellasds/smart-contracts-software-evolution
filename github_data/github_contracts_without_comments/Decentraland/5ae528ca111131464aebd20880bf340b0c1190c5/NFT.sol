pragma solidity ^0.4.15;

contract nft {
  function totalsupply() public constant returns (uint);
  function balanceof(address) public constant returns (uint);

  function tokenofownerbyindex(address owner, uint index) public constant returns (uint);
  function ownerof(uint tokenid) public constant returns (address);

  function transfer(address to, uint tokenid) public;
  function takeownership(uint tokenid) public;
  function transferfrom(address from, address to, uint tokenid) public;
  function approve(address beneficiary, uint tokenid) public;

  function metadata(uint tokenid) public constant returns (string);
}

contract nftevents {
  event created(uint tokenid, address owner, string metadata);
  event destroyed(uint tokenid, address owner);

  event transferred(uint tokenid, address from, address to);
  event approval(address owner, address beneficiary, uint tokenid);

  event metadataupdated(uint tokenid, address owner, string data);
}
