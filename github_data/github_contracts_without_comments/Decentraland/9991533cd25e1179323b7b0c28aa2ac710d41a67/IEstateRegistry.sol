pragma solidity ^0.4.22;


contract iestateregistry {
  function mint(address to, string metadata) external returns (uint256);

  

  event createestate(
    address indexed owner,
    uint256 indexed estateid,
    string data
  );

  event addland(
    uint256 indexed estateid,
    uint256 indexed landid
  );

  event removeland(
    uint256 indexed estateid,
    uint256 indexed landid,
    address indexed destinatary
  );

  event update(
    uint256 indexed assetid,
    address indexed holder,
    address indexed operator,
    string data
  );

  event updateoperator(
    uint256 indexed estateid,
    address indexed operator
  );

  event setlandregistry(
    address indexed registry
  );
}
