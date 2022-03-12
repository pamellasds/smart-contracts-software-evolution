pragma solidity ^0.4.23;


contract landregistry {
  function decodetokenid(uint value) external pure returns (int, int);
  function updatelanddata(int x, int y, string data) external;
  function setupdateoperator(uint256 assetid, address operator) external;
  function setmanyupdateoperator(uint256[] landids, address operator) external;
  function ping() public;
  function ownerof(uint256 tokenid) public returns (address);
  function safetransferfrom(address, address, uint256) public;
  function updateoperator(uint256 landid) public returns (address);
}


contract estatestorage {
  bytes4 internal constant interfaceid_getmetadata = bytes4(keccak256());
  bytes4 internal constant interfaceid_verifyfingerprint = bytes4(
    keccak256()
  );

  landregistry public registry;

  
  mapping(uint256 => uint256[]) public estatelandids;

  
  mapping(uint256 => uint256) public landidestate;

  
  mapping(uint256 => mapping(uint256 => uint256)) public estatelandindex;

  
  mapping(uint256 => string) internal estatedata;

  
  mapping (uint256 => address) public updateoperator;

  
  mapping(address => mapping(address => bool)) public updatemanager;

}
