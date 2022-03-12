pragma solidity ^0.4.13;

contract ownable {
  address public owner;


  event ownershiptransferred(address indexed previousowner, address indexed newowner);


  
  function ownable() {
    owner = msg.sender;
  }


  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferownership(address newowner) onlyowner public {
    require(newowner != address(0));
    ownershiptransferred(owner, newowner);
    owner = newowner;
  }

}

contract nft {
  function totalsupply() constant returns (uint);
  function balanceof(address) constant returns (uint);

  function tokenofownerbyindex(address owner, uint index) constant returns (uint);
  function ownerof(uint tokenid) constant returns (address);

  function transfer(address to, uint tokenid);
  function takeownership(uint tokenid);
  function approve(address beneficiary, uint tokenid);

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

contract basicnft is nft, nftevents {

  uint public totaltokens;

  
  mapping(address => uint[]) public ownedtokens;
  mapping(address => uint) _virtuallength;
  mapping(uint => uint) _tokenindexinownerarray;

  
  mapping(uint => address) public tokenowner;

  
  mapping(uint => address) public allowedtransfer;

  
  mapping(uint => string) public tokenmetadata;

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

  function approve(address beneficiary, uint tokenid) public {
    require(msg.sender == tokenowner[tokenid]);

    if (allowedtransfer[tokenid] != 0) {
      allowedtransfer[tokenid] = 0;
      tokentransferdisallowed(tokenid, allowedtransfer[tokenid]);
    }
    allowedtransfer[tokenid] = beneficiary;
    tokentransferallowed(tokenid, beneficiary);
  }

  function metadata(uint tokenid) constant public returns (string) {
    return tokenmetadata[tokenid];
  }

  function updatetokenmetadata(uint tokenid, string _metadata) public {
    require(msg.sender == tokenowner[tokenid]);
    tokenmetadata[tokenid] = _metadata;
    tokenmetadataupdated(tokenid, msg.sender, _metadata);
  }

  function _transfer(address from, address to, uint tokenid) internal {
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

contract landtoken is ownable, basicnft {

  string public name = ;
  string public symbol = ;

  mapping (uint => uint) public latestping;

  event tokenping(uint tokenid);

  function assignnewparcel(address beneficiary, uint tokenid, string _metadata) onlyowner public {
    require(tokenowner[tokenid] == 0);

    latestping[tokenid] = now;
    _addtokento(beneficiary, tokenid);
    totaltokens++;
    tokenmetadata[tokenid] = _metadata;

    tokencreated(tokenid, beneficiary, _metadata);
  }

  function ping(uint tokenid) public {
    require(msg.sender == tokenowner[tokenid]);

    latestping[tokenid] = now;

    tokenping(tokenid);
  }

  function buildtokenid(uint x, uint y) public constant returns (uint256) {
    return uint256(sha3(x, , y));
  }

  function exists(uint x, uint y) public constant returns (bool) {
    return ownerofland(x, y) != 0;
  }

  function ownerofland(uint x, uint y) public constant returns (address) {
    return tokenowner[buildtokenid(x, y)];
  }

  function transferland(address to, uint x, uint y) public {
    return transfer(to, buildtokenid(x, y));
  }

  function takeland(uint x, uint y) public {
    return takeownership(buildtokenid(x, y));
  }

  function approvelandtransfer(address to, uint x, uint y) public {
    return approve(to, buildtokenid(x, y));
  }

  function landmetadata(uint x, uint y) constant public returns (string) {
    return tokenmetadata[buildtokenid(x, y)];
  }

  function updatelandmetadata(uint x, uint y, string _metadata) public {
    return updatetokenmetadata(buildtokenid(x, y), _metadata);
  }

  function updatemanylandmetadata(uint[] x, uint[] y, string _metadata) public {
    for (uint i = 0; i < x.length; i++) {
      updatetokenmetadata(buildtokenid(x[i], y[i]), _metadata);
    }
  }

  function claimforgottenparcel(address beneficiary, uint tokenid) onlyowner public {
    require(tokenowner[tokenid] != 0);
    require(latestping[tokenid] < now);
    require(now  latestping[tokenid] > 1 years);

    address oldowner = tokenowner[tokenid];
    latestping[tokenid] = now;
    _transfer(oldowner, beneficiary, tokenid);

    tokentransferred(tokenid, oldowner, beneficiary);
  }
}

