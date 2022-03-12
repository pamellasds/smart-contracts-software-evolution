pragma solidity ^0.4.23;

import ;

import ;

import ;

import ;

import ;

import ;

import ;



contract landregistry is storage, ownable, fullassetregistry, ilandregistry {
  bytes4 constant public get_metadata = bytes4(keccak256());

  function initialize(bytes) external {
    _name = ;
    _symbol = ;
    _description = ;
  }

  modifier onlyproxyowner() {
    require(msg.sender == proxyowner, );
    _;
  }

  
  
  modifier onlyownerof(uint256 assetid) {
    require(
      msg.sender == _ownerof(assetid),
      
    );
    _;
  }

  modifier onlyupdateauthorized(uint256 tokenid) {
    require(
      msg.sender == _ownerof(tokenid) || _isupdateauthorized(msg.sender, tokenid),
      
    );
    _;
  }

  function isupdateauthorized(address operator, uint256 assetid) external view returns (bool) {
    return _isupdateauthorized(operator, assetid);
  }

  function _isupdateauthorized(address operator, uint256 assetid) internal view returns (bool) {
    return operator == _ownerof(assetid) || updateoperator[assetid] == operator;
  }

  function authorizedeploy(address beneficiary) external onlyproxyowner {
    authorizeddeploy[beneficiary] = true;
  }

  function forbiddeploy(address beneficiary) external onlyproxyowner {
    authorizeddeploy[beneficiary] = false;
  }

  function assignnewparcel(int x, int y, address beneficiary) external onlyproxyowner {
    _generate(_encodetokenid(x, y), beneficiary);
  }

  function assignmultipleparcels(int[] x, int[] y, address beneficiary) external onlyproxyowner {
    for (uint i = 0; i < x.length; i++) {
      _generate(_encodetokenid(x[i], y[i]), beneficiary);
    }
  }

  
  
  function ping() external {
    
    latestping[msg.sender] = block.timestamp;
  }

  function setlatesttonow(address user) external {
    require(msg.sender == proxyowner || _isapprovedforall(msg.sender, user), );
    
    latestping[user] = block.timestamp;
  }

  
  
  function encodetokenid(int x, int y) external pure returns (uint) {
    return _encodetokenid(x, y);
  }

  function _encodetokenid(int x, int y) internal pure returns (uint result) {
    require(
      1000000 < x && x < 1000000 && 1000000 < y && y < 1000000,
      
    );
    return _unsafeencodetokenid(x, y);
  }

  function _unsafeencodetokenid(int x, int y) internal pure returns (uint) {
    return ((uint(x) * factor) & clearlow) | (uint(y) & clearhigh);
  }

  function decodetokenid(uint value) external pure returns (int, int) {
    return _decodetokenid(value);
  }

  function _unsafedecodetokenid(uint value) internal pure returns (int x, int y) {
    x = expandnegative128bitcast((value & clearlow) >> 128);
    y = expandnegative128bitcast(value & clearhigh);
  }

  function _decodetokenid(uint value) internal pure returns (int x, int y) {
    (x, y) = _unsafedecodetokenid(value);
    require(
      1000000 < x && x < 1000000 && 1000000 < y && y < 1000000,
      
    );
  }

  function expandnegative128bitcast(uint value) internal pure returns (int) {
    if (value & (1<<127) != 0) {
      return int(value | clearlow);
    }
    return int(value);
  }

  function exists(int x, int y) external view returns (bool) {
    return _exists(x, y);
  }

  function _exists(int x, int y) internal view returns (bool) {
    return _exists(_encodetokenid(x, y));
  }

  function ownerofland(int x, int y) external view returns (address) {
    return _ownerofland(x, y);
  }

  function _ownerofland(int x, int y) internal view returns (address) {
    return _ownerof(_encodetokenid(x, y));
  }

  function owneroflandmany(int[] x, int[] y) external view returns (address[]) {
    require(x.length > 0, );
    require(x.length == y.length, );

    address[] memory addrs = new address[](x.length);
    for (uint i = 0; i < x.length; i++) {
      addrs[i] = _ownerofland(x[i], y[i]);
    }

    return addrs;
  }

  function landof(address owner) external view returns (int[], int[]) {
    uint256 len = _assetsof[owner].length;
    int[] memory x = new int[](len);
    int[] memory y = new int[](len);

    int assetx;
    int assety;
    for (uint i = 0; i < len; i++) {
      (assetx, assety) = _decodetokenid(_assetsof[owner][i]);
      x[i] = assetx;
      y[i] = assety;
    }

    return (x, y);
  }

  function tokenmetadata(uint256 assetid) external view returns (string) {
    return _tokenmetadata(assetid);
  }

  function _tokenmetadata(uint256 assetid) internal view returns (string) {
    address _owner = _ownerof(assetid);
    if (_iscontract(_owner)) {
      if ((erc165(_owner)).supportsinterface(get_metadata)) {
        return imetadataholder(_owner).getmetadata(assetid);
      }
    }
    return _assetdata[assetid];
  }

  function landdata(int x, int y) external view returns (string) {
    return _tokenmetadata(_encodetokenid(x, y));
  }

  
  
  function transferland(int x, int y, address to) external {
    uint256 tokenid = _encodetokenid(x, y);
    _dotransferfrom(
      _ownerof(tokenid),
      to,
      tokenid,
      ,
      msg.sender,
      true
    );
  }

  function transfermanyland(int[] x, int[] y, address to) external {
    require(x.length > 0, );
    require(x.length == y.length, );

    for (uint i = 0; i < x.length; i++) {
      uint256 tokenid = _encodetokenid(x[i], y[i]);
      _dotransferfrom(
        _ownerof(tokenid),
        to,
        tokenid,
        ,
        msg.sender,
        true
      );
    }
  }

  function transferlandtoestate(int x, int y, uint256 estateid) external {
    uint256 tokenid = _encodetokenid(x, y);
    _dotransferfrom(
      _ownerof(tokenid),
      address(estateregistry),
      tokenid,
      tobytes(estateid),
      msg.sender,
      true
    );
  }

  function transfermanylandtoestate(int[] x, int[] y, uint256 estateid) external {
    require(x.length > 0, );
    require(x.length == y.length, );

    for (uint i = 0; i < x.length; i++) {
      uint256 tokenid = _encodetokenid(x[i], y[i]);
      _dotransferfrom(
        _ownerof(tokenid),
        address(estateregistry),
        tokenid,
        tobytes(estateid),
        msg.sender,
        true
      );
    }
  }

  function setupdateoperator(uint256 assetid, address operator) external onlyownerof(assetid) {
    updateoperator[assetid] = operator;
    emit updateoperator(assetid, operator);
  }

  
  
  event estateregistryset(address indexed registry);

  function setestateregistry(address registry) external onlyproxyowner {
    estateregistry = iestateregistry(registry);
    emit estateregistryset(registry);
  }

  function createestate(int[] x, int[] y, address beneficiary) external returns (uint256) {
    
    return _createestate(x, y, beneficiary, );
  }

  function createestatewithmetadata(
    int[] x,
    int[] y,
    address beneficiary,
    string metadata
  )
    external
    returns (uint256)
  {
    
    return _createestate(x, y, beneficiary, metadata);
  }

  function _createestate(
    int[] x,
    int[] y,
    address beneficiary,
    string metadata
  )
    internal
    returns (uint256)
  {
    require(x.length > 0, );
    require(x.length == y.length, );
    require(address(estateregistry) != 0, );

    uint256 estatetokenid = estateregistry.mint(beneficiary, metadata);
    bytes memory estatetokenidbytes = tobytes(estatetokenid);

    for (uint i = 0; i < x.length; i++) {
      uint256 tokenid = _encodetokenid(x[i], y[i]);
      _movetoken(
        _ownerof(tokenid),
        address(estateregistry),
        tokenid,
        estatetokenidbytes,
        this,
        true
      );
    }

    return estatetokenid;
  }

  function tobytes(uint256 x) internal pure returns (bytes b) {
    b = new bytes(32);
    
    assembly { mstore(add(b, 32), x) }
  }

  
  
  function updatelanddata(
    int x,
    int y,
    string data
  )
    external
    onlyupdateauthorized(_encodetokenid(x, y))
  {
    return _updatelanddata(x, y, data);
  }

  function _updatelanddata(
    int x,
    int y,
    string data
  )
    internal
    onlyupdateauthorized(_encodetokenid(x, y))
  {
    uint256 assetid = _encodetokenid(x, y);
    address owner = _holderof[assetid];

    _update(assetid, data);

    emit update(
      assetid,
      owner,
      msg.sender,
      data
    );
  }

  function updatemanylanddata(int[] x, int[] y, string data) external {
    require(x.length > 0, );
    require(x.length == y.length, );
    for (uint i = 0; i < x.length; i++) {
      _updatelanddata(x[i], y[i], data);
    }
  }

  function _dotransferfrom(
    address from,
    address to,
    uint256 assetid,
    bytes userdata,
    address operator,
    bool docheck
  )
    internal
  {
    updateoperator[assetid] = address(0);

    super._dotransferfrom(
      from,
      to,
      assetid,
      userdata,
      operator,
      docheck
    );
  }

  function _iscontract(address addr) internal view returns (bool) {
    uint size;
    
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}
