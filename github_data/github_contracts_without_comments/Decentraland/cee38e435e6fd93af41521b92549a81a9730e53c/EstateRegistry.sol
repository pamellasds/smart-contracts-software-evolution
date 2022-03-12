pragma solidity ^0.4.23;


import ;
import ;
import ;
import ;

import ;
import ;



contract estateregistry is migratable, erc721token, erc721receiver, ownable, iestateregistry, estatestorage {
  modifier cantransfer(uint256 estateid) {
    require(isapprovedorowner(msg.sender, estateid), );
    _;
  }

  modifier onlyregistry() {
    require(msg.sender == address(registry), );
    _;
  }

  modifier onlyupdateauthorized(uint256 estateid) {
    require(_isupdateauthorized(msg.sender, estateid), );
    _;
  }

  
  function mint(address to, string metadata) external onlyregistry returns (uint256) {
    return _mintestate(to, metadata);
  }

  
  function onerc721received(
    address _operator,
    address _from,
    uint256 _tokenid,
    bytes _data
  )
    public
    onlyregistry
    returns (bytes4)
  {
    uint256 estateid = _bytestouint(_data);
    _pushlandid(estateid, _tokenid);
    return erc721_received;
  }

  
  function transferland(
    uint256 estateid,
    uint256 landid,
    address destinatary
  )
    external
    cantransfer(estateid)
  {
    return _transferland(estateid, landid, destinatary);
  }

  
  function transfermanylands(
    uint256 estateid,
    uint256[] landids,
    address destinatary
  )
    external
    cantransfer(estateid)
  {
    uint length = landids.length;
    for (uint i = 0; i < length; i++) {
      _transferland(estateid, landids[i], destinatary);
    }
  }

  
  function getlandestateid(uint256 landid) external view returns (uint256) {
    return landidestate[landid];
  }

  function setlandregistry(address _registry) external onlyowner {
    require(_registry.iscontract(), );
    require(_registry != 0, );
    registry = landregistry(_registry);
    emit setlandregistry(registry);
  }

  function ping() external {
    registry.ping();
  }

  
  function getestatesize(uint256 estateid) external view returns (uint256) {
    return estatelandids[estateid].length;
  }

  
  function updatemetadata(
    uint256 estateid,
    string metadata
  )
    external
    onlyupdateauthorized(estateid)
  {
    _updatemetadata(estateid, metadata);

    emit update(
      estateid,
      ownerof(estateid),
      msg.sender,
      metadata
    );
  }

  function getmetadata(uint256 estateid) external view returns (string) {
    return estatedata[estateid];
  }

  function setupdateoperator(uint256 estateid, address operator) external cantransfer(estateid) {
    updateoperator[estateid] = operator;
    emit updateoperator(estateid, operator);
  }

  function isupdateauthorized(address operator, uint256 estateid) external view returns (bool) {
    return _isupdateauthorized(operator, estateid);
  }

  function initialize(
    string _name,
    string _symbol,
    address _registry
  )
    public
    isinitializer(, )
  {
    require(_registry != 0, );
    
    erc721token.initialize(_name, _symbol);
    ownable.initialize(msg.sender);
    registry = landregistry(_registry);
  }

  
  function _supportsinterface(bytes4 _interfaceid)
    internal
    view
    returns (bool)
  {
    return super._supportsinterface(_interfaceid) || 
      _interfaceid == interfaceid_getmetadata;
  }

  
  function safetransfermanyfrom(address from, address to, uint256[] estateids) public {
    safetransfermanyfrom(
      from,
      to,
      estateids,
      
    );
  }

  
  function safetransfermanyfrom(
    address from,
    address to,
    uint256[] estateids,
    bytes data
  )
    public
  {
    for (uint i = 0; i < estateids.length; i++) {
      safetransferfrom(
        from,
        to,
        estateids[i],
        data
      );
    }
  }

  
  function _mintestate(address to, string metadata) internal returns (uint256) {
    require(to != address(0), );
    uint256 estateid = _getnewestateid();
    _mint(to, estateid);
    _updatemetadata(estateid, metadata);
    emit createestate(to, estateid, metadata);
    return estateid;
  }

  
  function _updatemetadata(uint256 estateid, string metadata) internal {
    estatedata[estateid] = metadata;
  }

  
  function _getnewestateid() internal view returns (uint256) {
    return totalsupply().add(1);
  }

  
  function _pushlandid(uint256 estateid, uint256 landid) internal {
    require(exists(estateid), );
    require(landidestate[landid] == 0, );
    require(registry.ownerof(landid) == address(this), );

    estatelandids[estateid].push(landid);

    landidestate[landid] = estateid;

    estatelandindex[estateid][landid] = estatelandids[estateid].length;

    emit addland(estateid, landid);
  }

  
  function _transferland(
    uint256 estateid,
    uint256 landid,
    address destinatary
  )
    internal
  {
    require(destinatary != address(0), );

    uint256[] storage landids = estatelandids[estateid];
    mapping(uint256 => uint256) landindex = estatelandindex[estateid];

    
    require(landindex[landid] != 0, );

    uint lastindexinarray = landids.length.sub(1);

    
    uint indexinarray = landindex[landid].sub(1);

    
    uint temptokenid = landids[lastindexinarray];

    
    landindex[temptokenid] = indexinarray.add(1);
    landids[indexinarray] = temptokenid;

    
    delete landids[lastindexinarray];
    landids.length = lastindexinarray;

    
    landindex[landid] = 0;

    
    landidestate[landid] = 0;

    registry.safetransferfrom(this, destinatary, landid);

    emit removeland(estateid, landid, destinatary);
  }

  function _isupdateauthorized(address operator, uint256 estateid) internal view returns (bool) {
    return isapprovedorowner(operator, estateid) || updateoperator[estateid] == operator;
  }

  function _bytestouint(bytes b) internal pure returns (uint256) {
    bytes32 out;

    for (uint i = 0; i < b.length; i++) {
      out |= bytes32(b[i] & 0xff) >> i.mul(8);
    }

    return uint256(out);
  }

  
  function updatelanddata(uint256 estateid, uint256 landid, string data) public {
    _updatelanddata(estateid, landid, data);
  }

  
  function updatemanylanddata(uint256 estateid, uint256[] landids, string data) public {
    uint length = landids.length;
    for (uint i = 0; i < length; i++) {
      _updatelanddata(estateid, landids[i], data);
    }
  }

  function _updatelanddata(uint256 estateid, uint256 landid, string data) internal onlyupdateauthorized(estateid) {
    require(landidestate[landid] == estateid, );
    int x;
    int y;
    (x, y) = registry.decodetokenid(landid);
    registry.updatelanddata(x, y, data);
  }
}
