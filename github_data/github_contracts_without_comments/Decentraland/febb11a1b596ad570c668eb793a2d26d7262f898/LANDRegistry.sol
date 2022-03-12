pragma solidity ^0.4.18;

import ;

import ;

import ;

import ;

import ;

contract landregistry is storage,
  ownable, fullassetregistry,
  ilandregistry
{

  function initialize(bytes) public {
    _name = ;
    _symbol = ;
    _description = ;
  }

  modifier onlyproxyowner() {
    require(msg.sender == proxyowner);
    _;
  }

  
  
  modifier onlyownerof(uint256 assetid) {
    require(msg.sender == ownerof(assetid));
    _;
  }

  modifier onlyupdateauthorized(uint256 tokenid) {
    require(msg.sender == ownerof(tokenid) || isupdateauthorized(msg.sender, tokenid));
    _;
  }

  function isupdateauthorized(address operator, uint256 assetid) public view returns (bool) {
    return operator == ownerof(assetid) || updateoperator[assetid] == operator;
  }

  function authorizedeploy(address beneficiary) public onlyproxyowner {
    authorizeddeploy[beneficiary] = true;
  }
  function forbiddeploy(address beneficiary) public onlyproxyowner {
    authorizeddeploy[beneficiary] = false;
  }

  function assignnewparcel(int x, int y, address beneficiary) public onlyproxyowner {
    _generate(encodetokenid(x, y), beneficiary);
  }

  function assignmultipleparcels(int[] x, int[] y, address beneficiary) public onlyproxyowner {
    for (uint i = 0; i < x.length; i++) {
      _generate(encodetokenid(x[i], y[i]), beneficiary);
    }
  }

  
  
  function ping() public {
    latestping[msg.sender] = now;
  }

  function setlatesttonow(address user) public {
    require(msg.sender == proxyowner || isapprovedforall(msg.sender, user));
    latestping[user] = now;
  }

  
  
  function encodetokenid(int x, int y) view public returns (uint) {
    return ((uint(x) * factor) & clearlow) | (uint(y) & clearhigh);
  }

  function decodetokenid(uint value) view public returns (int, int) {
    uint x = (value & clearlow) >> 128;
    uint y = (value & clearhigh);
    return (expandnegative128bitcast(x), expandnegative128bitcast(y));
  }

  function expandnegative128bitcast(uint value) pure internal returns (int) {
    if (value & (1<<127) != 0) {
      return int(value | clearlow);
    }
    return int(value);
  }

  function exists(int x, int y) view public returns (bool) {
    return exists(encodetokenid(x, y));
  }

  function ownerofland(int x, int y) view public returns (address) {
    return ownerof(encodetokenid(x, y));
  }

  function owneroflandmany(int[] x, int[] y) view public returns (address[]) {
    require(x.length > 0);
    require(x.length == y.length);

    address[] memory addrs = new address[](x.length);
    for (uint i = 0; i < x.length; i++) {
      addrs[i] = ownerofland(x[i], y[i]);
    }

    return addrs;
  }

  function landof(address owner) public view returns (int[], int[]) {
    uint256 len = _assetsof[owner].length;
    int[] memory x = new int[](len);
    int[] memory y = new int[](len);

    int assetx;
    int assety;
    for (uint i = 0; i < len; i++) {
      (assetx, assety) = decodetokenid(_assetsof[owner][i]);
      x[i] = assetx;
      y[i] = assety;
    }

    return (x, y);
  }

  function landdata(int x, int y) view public returns (string) {
    return tokenmetadata(encodetokenid(x, y));
  }

  
  
  function transferland(int x, int y, address to) public {
    uint256 tokenid = encodetokenid(x, y);
    safetransferfrom(ownerof(tokenid), to, tokenid);
  }

  function transfermanyland(int[] x, int[] y, address to) public {
    require(x.length > 0);
    require(x.length == y.length);

    for (uint i = 0; i < x.length; i++) {
      uint256 tokenid = encodetokenid(x[i], y[i]);
      safetransferfrom(ownerof(tokenid), to, tokenid);
    }
  }

  function setupdateoperator(uint256 assetid, address operator) public onlyownerof(assetid) {
    updateoperator[assetid] = operator;
  }

  
  
  function updatelanddata(int x, int y, string data) public onlyupdateauthorized (encodetokenid(x, y)) {
    uint256 assetid = encodetokenid(x, y);
    _update(assetid, data);

    update(assetid, _holderof[assetid], msg.sender, data);
  }

  function updatemanylanddata(int[] x, int[] y, string data) public {
    require(x.length > 0);
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      updatelanddata(x[i], y[i], data);
    }
  }

  function _dotransferfrom(
    address from,
    address to,
    uint256 assetid,
    bytes userdata,
    address operator,
    bool docheck
  ) internal {
    updateoperator[assetid] = address(0);
    super._dotransferfrom(from, to, assetid, userdata, operator, docheck);
  }
}
