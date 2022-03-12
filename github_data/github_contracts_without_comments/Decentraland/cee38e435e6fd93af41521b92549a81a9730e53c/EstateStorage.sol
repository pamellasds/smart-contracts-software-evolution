pragma solidity ^0.4.23;


contract landregistry {
  function ping() public;
  function ownerof(uint256 tokenid) public returns (address);
  function safetransferfrom(address, address, uint256) public;
  function decodetokenid(uint value) external pure returns (int, int);
  function updatelanddata(int x, int y, string data) external;
}


contract estatestorage {
  bytes4 internal constant interfaceid_getmetadata = bytes4(keccak256());

  landregistry public registry;

  
  mapping(uint256 => uint256[]) public estatelandids;

  
  mapping(uint256 => uint256) public landidestate;

  
  mapping(uint256 => mapping(uint256 => uint256)) public estatelandindex;

  
  mapping(uint256 => string) internal estatedata;

  
  mapping (uint256 => address) internal updateoperator;
}
