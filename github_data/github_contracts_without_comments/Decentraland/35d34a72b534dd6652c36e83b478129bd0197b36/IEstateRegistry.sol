pragma solidity ^0.4.22;


contract iestateregistry {
  function mint(address to, string metadata) external returns (uint256);
  function ownerof(uint256 _tokenid) public view returns (address _owner); 

  

  event createestate(
    address indexed _owner,
    uint256 indexed _estateid,
    string _data
  );

  event addland(
    uint256 indexed _estateid,
    uint256 indexed _landid
  );

  event removeland(
    uint256 indexed _estateid,
    uint256 indexed _landid,
    address indexed _destinatary
  );

  event update(
    uint256 indexed _assetid,
    address indexed _holder,
    address indexed _operator,
    string _data
  );

  event updateoperator(
    uint256 indexed _estateid,
    address indexed _operator
  );

  event updatemanager(
    address indexed _owner,
    address indexed _operator,
    address indexed _caller,
    bool _approved
  );

  event setlandregistry(
    address indexed _registry
  );
}
