pragma solidity ^0.4.15;

contract nft {
  function totalsupply() constant returns (uint);
  function balanceof(address) constant returns (uint);

  function tokenofownerbyindex(address owner, uint index) constant returns (uint);
  function ownerof(uint tokenid) constant returns (address);

  function transfer(address to, uint tokenid);
  function takeownership(uint tokenid);
  function transferfrom(address from, address to, uint tokenid);
  function approve(address beneficiary, uint tokenid);

  function metadata(uint tokenid) constant returns (string);
}

contract nftevents {
  event created(uint tokenid, address owner, string metadata);
  event destroyed(uint tokenid, address owner);

  event transferred(uint tokenid, address from, address to);
  event approval(address owner, address beneficiary, uint tokenid);

  event metadataupdated(uint tokenid, address owner, string data);
}
