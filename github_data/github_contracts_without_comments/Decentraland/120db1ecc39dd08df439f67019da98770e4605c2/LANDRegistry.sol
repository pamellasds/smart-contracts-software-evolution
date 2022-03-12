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

  function initialize(bytes ) public {
    _name = ;
    _symbol = ;
    _description = ;
  }

  
  
  function assignnewparcel(int x, int y, address beneficiary, string data) public {
    generate(encodetokenid(x, y), beneficiary, data);
  }

  function assignnewparcel(int x, int y, address beneficiary) public {
    generate(encodetokenid(x, y), beneficiary, );
  }

  function assignmultipleparcels(int[] x, int[] y, address beneficiary) public {
    for (uint i = 0; i < x.length; i++) {
      generate(encodetokenid(x[i], y[i]), beneficiary, );
    }
  }

  function generate(uint256 assetid, address beneficiary, string data) onlyowner public {
    dogenerate(assetid, beneficiary, data);
  }

  function destroy(uint256 assetid) onlyowner public {
    _removeassetfrom(_holderof[assetid], assetid);
    destroy(_holderof[assetid], assetid, msg.sender);
  }

  
  
  function ping() public {
    latestping[msg.sender] = now;
  }

  function setlatesttonow(address user) onlyowner public {
    latestping[user] = now;
  }

  function clearland(int[] x, int[] y) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      uint landid = encodetokenid(x[i], y[i]);
      address holder = holderof(landid);
      if (latestping[holder] < now  1 years) {
        _removeassetfrom(holder, landid);
        destroy(holder, landid, msg.sender);
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

  function expandnegative128bitcast(uint value) view public returns (int) {
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

  function landdata(int x, int y) view public returns (string) {
    return assetdata(encodetokenid(x, y));
  }

  
  
  function transferland(int x, int y, address to) public {
    return transfer(to, encodetokenid(x, y));
  }

  function transfermanyland(int[] x, int[] y, address to) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      return transfer(to, encodetokenid(x[i], y[i]));
    }
  }

  
  
  function updatelanddata(int x, int y, string data) public {
    return update(encodetokenid(x, y), data);
  }

  function updatemanylanddata(int[] x, int[] y, string data) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      update(encodetokenid(x[i], y[i]), data);
    }
  }
}
