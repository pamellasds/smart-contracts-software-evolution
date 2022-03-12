pragma solidity ^0.4.18;

import ;

import ;

import ;

import ;

contract standardassetregistry is storage, iassetregistry {
  using safemath for uint256;

  
  
  function name() public view returns (string) {
    return _name;
  }

  function symbol() public view returns (string) {
    return _symbol;
  }

  function description() public view returns (string) {
    return _description;
  }

  function totalsupply() public view returns (uint256) {
    return _count;
  }

  
  
  function exists(uint256 assetid) public view returns (bool) {
    return _holderof[assetid] != 0;
  }

  function holderof(uint256 assetid) public view returns (address) {
    return _holderof[assetid];
  }

  function assetdata(uint256 assetid) public view returns (string) {
    return _assetdata[assetid];
  }

  
  
  function assetscount(address holder) public view returns (uint256) {
    return _assetsof[holder].length;
  }

  function assetbyindex(address holder, uint256 index) public view returns (uint256) {
    return _assetsof[holder][index];
  }

  function assetsof(address holder) public view returns (uint256[]) {
    return allassetsof(holder);
  }

  function allassetsof(address holder) public view returns (uint256[]) {
    uint size = _assetsof[holder].length;
    uint[] memory result = new uint[](size);
    for (uint i = 0; i < size; i++) {
      result[i] = _assetsof[holder][i];
    }
    return result;
  }

  
  
  function isoperatorauthorizedfor(address operator, address assetholder)
    public view returns (bool)
  {
    return _operators[assetholder][operator];
  }

  function authorizeoperator(address operator, bool _authorized) public {
    if (_authorized) {
      require(!isoperatorauthorizedfor(operator, msg.sender));
      _addauthorization(operator, msg.sender);
    } else {
      require(isoperatorauthorizedfor(operator, msg.sender));
      _clearauthorization(operator, msg.sender);
    }
    authorizeoperator(operator, msg.sender, _authorized);
  }

  function _addauthorization(address operator, address holder) private {
    _operators[holder][operator] = true;
  }

  function _clearauthorization(address operator, address holder) private {
    _operators[holder][operator] = false;
  }

  
  
  function _addassetto(address to, uint256 assetid) internal {
    _holderof[assetid] = to;

    uint256 length = assetscount(to);

    _assetsof[to].push(assetid);

    _indexofasset[assetid] = length;

    _count = _count.add(1);
  }

  function _addassetto(address to, uint256 assetid, string data) internal {
    _addassetto(to, assetid);

    _assetdata[assetid] = data;
  }

  function _removeassetfrom(address from, uint256 assetid) internal {
    uint256 assetindex = _indexofasset[assetid];
    uint256 lastassetindex = assetscount(from).sub(1);
    uint256 lastassetid = _assetsof[from][lastassetindex];

    _holderof[assetid] = 0;

    
    _assetsof[from][assetindex] = lastassetid;

    
    _assetsof[from][lastassetindex] = 0;
    _assetsof[from].length;

    
    if (_assetsof[from].length == 0) {
      delete _assetsof[from];
    }

    
    _indexofasset[assetid] = 0;
    _indexofasset[lastassetid] = assetindex;

    _count = _count.sub(1);
  }

  
  
  function generate(uint256 assetid) public {
    generate(assetid, msg.sender, );
  }

  function generate(uint256 assetid, string data) public {
    generate(assetid, msg.sender, data);
  }

  function generate(uint256 assetid, address _beneficiary, string data) public {
    dogenerate(assetid, _beneficiary, data);
  }

  function dogenerate(uint256 assetid, address _beneficiary, string data) internal {
    require(_holderof[assetid] == 0);

    _addassetto(_beneficiary, assetid, data);

    create(_beneficiary, assetid, msg.sender, data);
  }

  function destroy(uint256 assetid) public {
    address holder = _holderof[assetid];
    require(holder != 0);

    require(holder == msg.sender
         || isoperatorauthorizedfor(msg.sender, holder));

    _removeassetfrom(holder, assetid);

    destroy(holder, assetid, msg.sender);
  }

  
  
  modifier onlyholder(uint256 assetid) {
    require(_holderof[assetid] == msg.sender);
    _;
  }

  modifier onlyoperator(uint256 assetid) {
    require(_holderof[assetid] == msg.sender
         || isoperatorauthorizedfor(msg.sender, _holderof[assetid]));
    _;
  }

  function transfer(address to, uint256 assetid)
    onlyholder(assetid)
    public
  {
    return dosend(to, assetid, , 0, );
  }

  function transfer(address to, uint256 assetid, bytes _userdata)
    onlyholder(assetid)
    public
  {
    return dosend(to, assetid, _userdata, 0, );
  }

  function operatortransfer(
    address to, uint256 assetid, bytes userdata, bytes operatordata
  )
    onlyoperator(assetid)
    public
  {
    return dosend(to, assetid, userdata, msg.sender, operatordata);
  }

  function dosend(
    address to, uint256 assetid, bytes userdata, address operator, bytes operatordata
  )
    internal
  {
    address holder = _holderof[assetid];
    _removeassetfrom(holder, assetid);
    _addassetto(to, assetid);

    
    if (iscontract(to)) {
      require(_reentrancy == false);
      _reentrancy = true;
      iassetholder(to).onassetreceived(assetid, holder, to, userdata, operator, operatordata);
      _reentrancy = false;
    }

    transfer(holder, to, assetid, operator, userdata, operatordata);
  }

  
  
  modifier onlyifupdateallowed(uint256 assetid) {
    require(_holderof[assetid] == msg.sender
         || isoperatorauthorizedfor(msg.sender, _holderof[assetid]));
    _;
  }

  function update(uint256 assetid, string data) onlyifupdateallowed(assetid) public {
    _assetdata[assetid] = data;
    update(assetid, _holderof[assetid], msg.sender, data);
  }

  
  
  function iscontract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}
