pragma solidity ^0.4.18;

import ;

import ;

import ;

import ;

import ;

contract landregistry is storage,
  ownable, standardassetregistry,
  ilandregistry
{

  function initialize(bytes data) public {
    _name = ;
    _symbol = ;
    _description = ;
    super.initialize(data);
  }

  modifier onlyproxyowner() {
    require(msg.sender == proxyowner);
    _;
  }

  
  
  function authorizedeploy(address beneficiary) public onlyproxyowner {
    authorizeddeploy[beneficiary] = true;
  }
  function forbiddeploy(address beneficiary) public onlyproxyowner {
    authorizeddeploy[beneficiary] = false;
  }

  function assignnewparcel(int x, int y, address beneficiary) public {
    require(authorizeddeploy[msg.sender]);
    _generate(encodetokenid(x, y), beneficiary, );
  }

  function assignmultipleparcels(int[] x, int[] y, address beneficiary) public {
    require(authorizeddeploy[msg.sender]);
    for (uint i = 0; i < x.length; i++) {
      _generate(encodetokenid(x[i], y[i]), beneficiary, );
    }
  }

  function destroy(uint256 assetid) onlyproxyowner public {
    _destroy(assetid);
  }

  
  
  function ping() public {
    latestping[msg.sender] = now;
  }

  function setlatesttonow(address user) onlyproxyowner public {
    latestping[user] = now;
  }

  function clearland(int[] x, int[] y) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      uint landid = encodetokenid(x[i], y[i]);
      address holder = holderof(landid);
      if (latestping[holder] < now  1 years) {
        _destroy(landid);
      }
    }
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
    return holderof(encodetokenid(x, y));
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
    int[] memory x = new int[](_assetsof[owner].length);
    int[] memory y = new int[](_assetsof[owner].length);

    int assetx;
    int assety;
    uint length = _assetsof[owner].length;
    for (uint i = 0; i < length; i++) {
      (assetx, assety) = decodetokenid(_assetsof[owner][i]);
      x[i] = assetx;
      y[i] = assety;
    }

    return (x, y);
  }

  function landdata(int x, int y) view public returns (string) {
    return assetdata(encodetokenid(x, y));
  }

  
  
  function transferland(int x, int y, address to) public {
    transfer(to, encodetokenid(x, y));
  }

  function transfermanyland(int[] x, int[] y, address to) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      transfer(to, encodetokenid(x[i], y[i]));
    }
  }

  
  
  function updatelanddata(int x, int y, string data) public onlyoperatororholder(encodetokenid(x, y)) {
    return _update(encodetokenid(x, y), data);
  }

  function updatemanylanddata(int[] x, int[] y, string data) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      updatelanddata(x[i], y[i], data);
    }
  }
}
