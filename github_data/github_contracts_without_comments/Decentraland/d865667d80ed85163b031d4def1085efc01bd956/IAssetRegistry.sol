pragma solidity ^0.4.18;

interface iassetregistry {

  
  function name() public constant returns (string);
  function symbol() public constant returns (string);
  function description() public constant returns (string);
  function totalsupply() public constant returns (uint256);

  
  function exists(uint256 assetid) public constant returns (bool);
  function holderof(uint256 assetid) public constant returns (address);
  function assetdata(uint256 assetid) public constant returns (string);

  
  function assetscount(address holder) public constant returns (uint256);
  function assetbyindex(address holder, uint256 index) public constant returns (uint256);
  function allassetsof(address holder) public constant returns (uint256[]);

  
  function transfer(address to, uint256 assetid) public;
  function transfer(address to, uint256 assetid, bytes userdata) public;
  function operatortransfer(address to, uint256 assetid, bytes userdata, bytes operatordata) public;

  
  function update(uint256 assetid, string data) public;

  
  function generate(uint256 assetid, string data) public;
  function destroy(uint256 assetid) public;

  
  function authorizeoperator(address operator, bool authorized) public;

  
  function isoperatorauthorizedfor(address operator, address assetholder)
    public constant returns (bool);

  
  event transfer(
    address indexed from,
    address indexed to,
    uint256 indexed assetid,
    address operator,
    bytes userdata,
    bytes operatordata
  );
  event create(
    address indexed holder,
    uint256 indexed assetid,
    address indexed operator,
    string data
  );
  event update(
    uint256 indexed assetid,
    address indexed holder,
    address indexed operator,
    string data
  );
  event destroy(
    address indexed holder,
    uint256 indexed assetid,
    address indexed operator
  );
  event authorizeoperator(
    address indexed operator,
    address indexed holder,
    bool authorized
  );
}
