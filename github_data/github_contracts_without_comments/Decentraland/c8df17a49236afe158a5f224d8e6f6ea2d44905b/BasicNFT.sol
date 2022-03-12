pragma solidity ^0.4.15;

import ;

contract basicnft is nft, nftevents {

  uint public totaltokens;

  
  mapping(address => uint[]) public ownedtokens;
  mapping(address => uint) _virtuallength;
  mapping(uint => uint) _tokenindexinownerarray;

  
  mapping(uint => address) public tokenowner;

  
  mapping(uint => address) public allowedtransfer;

  
  mapping(uint => string) public _tokenmetadata;

  function totalsupply() public constant returns (uint) {
    return totaltokens;
  }

  function balanceof(address owner) public constant returns (uint) {
    return _virtuallength[owner];
  }

  function tokenofownerbyindex(address owner, uint index) public constant returns (uint) {
    require(index >= 0 && index < balanceof(owner));
    return ownedtokens[owner][index];
  }

  function getalltokens(address owner) public constant returns (uint[]) {
    uint size = _virtuallength[owner];
    uint[] memory result = new uint[](size);
    for (uint i = 0; i < size; i++) {
      result[i] = ownedtokens[owner][i];
    }
    return result;
  }

  function ownerof(uint tokenid) public constant returns (address) {
    return tokenowner[tokenid];
  }

  function transfer(address to, uint tokenid) public {
    require(tokenowner[tokenid] == msg.sender || allowedtransfer[tokenid] == msg.sender);
    return _transfer(tokenowner[tokenid], to, tokenid);
  }

  function takeownership(uint tokenid) public {
    require(allowedtransfer[tokenid] == msg.sender);
    return _transfer(tokenowner[tokenid], msg.sender, tokenid);
  }

  function transferfrom(address from, address to, uint tokenid) public {
    require(allowedtransfer[tokenid] == msg.sender);
    return _transfer(tokenowner[tokenid], to, tokenid);
  }

  function approve(address beneficiary, uint tokenid) public {
    require(msg.sender == tokenowner[tokenid]);

    if (allowedtransfer[tokenid] != 0) {
      allowedtransfer[tokenid] = 0;
    }
    allowedtransfer[tokenid] = beneficiary;
    approval(tokenowner[tokenid], beneficiary, tokenid);
  }

  function tokenmetadata(uint tokenid) constant public returns (string) {
    return _tokenmetadata[tokenid];
  }

  function metadata(uint tokenid) constant public returns (string) {
    return _tokenmetadata[tokenid];
  }

  function updatetokenmetadata(uint tokenid, string _metadata) public {
    require(msg.sender == tokenowner[tokenid]);
    _tokenmetadata[tokenid] = _metadata;
    metadataupdated(tokenid, msg.sender, _metadata);
  }

  function _transfer(address from, address to, uint tokenid) internal {
    _clearapproval(tokenid);
    _removetokenfrom(from, tokenid);
    _addtokento(to, tokenid);
    transferred(tokenid, from, to);
  }

  function _clearapproval(uint tokenid) internal {
    allowedtransfer[tokenid] = 0;
    approval(tokenowner[tokenid], 0, tokenid);
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
