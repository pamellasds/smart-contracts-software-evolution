pragma solidity ^0.4.15;

import ;

contract basicnft is nft, nftevents {

  uint public totaltokens;

  
  mapping(address => uint[]) public ownedtokens;
  mapping(address => uint) _virtuallength;
  mapping(uint => uint) _tokenindexinownerarray;

  
  mapping(uint => address) public tokenowner;

  
  mapping(uint => address) public allowedtransfer;

  
  mapping(uint => bytes) public tokenmetadata;

  function totalsupply() public constant returns (uint) {
    return totaltokens;
  }

  function balanceof(address owner) public constant returns (uint) {
    return _virtuallength[owner];
  }

  function tokenbyindex(address owner, uint index) public returns (uint) {
    return ownedtokens[owner][index];
  }

  function ownerof(uint tokenid) public returns (address) {
    return tokenowner[tokenid];
  }

  function transfer(address to, uint tokenid) public {
    require(msg.sender == tokenowner[tokenid]);
    return _transfer(msg.sender, to, tokenid);
  }

  function approve(address beneficiary, uint tokenid) public {
    require(msg.sender == beneficiary);

    if (allowedtransfer[tokenid] != 0) {
      allowedtransfer[tokenid] = 0;
      tokentransferdisallowed(tokenid, allowedtransfer[tokenid]);
    }
    allowedtransfer[tokenid] = beneficiary;
    tokentransferallowed(tokenid, beneficiary);
  }

  function transferfrom(address from, address to, uint tokenid) public {
    return _transfer(from, to, tokenid);
  }

  function metadata(uint tokenid) constant public returns (bytes) {
    return tokenmetadata[tokenid];
  }

  function updatetokenmetadata(uint tokenid, bytes _metadata) public {
    require(msg.sender == tokenowner[tokenid]);
    tokenmetadata[tokenid] = _metadata;
    tokenmetadataupdated(tokenid, msg.sender, _metadata);
  }

  function _transfer(address from, address to, uint tokenid) internal {
    require(tokenowner[tokenid] == from || allowedtransfer[tokenid] == from);

    allowedtransfer[tokenid] = 0;
    _removetokenfrom(from, tokenid);
    _addtokento(to, tokenid);
    tokentransferred(tokenid, from, to);
  }

  function _removetokenfrom(address from, uint tokenid) internal {
    require(_virtuallength[from] > 0);

    uint length = _virtuallength[from];
    uint index = _tokenindexinownerarray[tokenid];
    uint swaptoken = ownedtokens[from][length  1];

    ownedtokens[from][index] = swaptoken;
    _tokenindexinownerarray[swaptoken] = index;
    _virtuallength[from];
  }

  function _addtokento(address owner, uint tokenid) internal {
    if (ownedtokens[owner].length == _virtuallength[owner]) {
      ownedtokens[owner].push(tokenid);
    } else {
      ownedtokens[owner][_virtuallength[owner]] = tokenid;
    }
    tokenowner[tokenid] = owner;
    _tokenindexinownerarray[tokenid] = _virtuallength[owner];
    _virtuallength[owner]++;
  }
}
