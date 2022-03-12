pragma solidity ^0.4.15;

contract nft {
  function totalsupply() constant returns (uint);
  function balanceof(address) constant returns (uint);

  function tokenbyindex(address owner, uint index) constant returns (uint);
  function ownerof(uint tokenid) constant returns (address);

  function transfer(address to, uint tokenid);
  function approve(address beneficiary, uint tokenid);

  function transferfrom(address from, address to, uint tokenid);

  function metadata(uint tokenid) constant returns (string);
}

contract nftevents {
  event tokencreated(uint tokenid, address owner, string metadata);
  event tokendestroyed(uint tokenid, address owner);

  event tokentransferred(uint tokenid, address from, address to);
  event tokentransferallowed(uint tokenid, address beneficiary);
  event tokentransferdisallowed(uint tokenid, address beneficiary);

  event tokenmetadataupdated(uint tokenid, address owner, string data);
}
