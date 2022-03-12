pragma solidity ^0.4.18;

interface ilandregistry {

  
  function assignnewparcel(int x, int y, address beneficiary) external;
  function assignmultipleparcels(int[] x, int[] y, address beneficiary) external;

  
  function ping() external;

  
  function encodetokenid(int x, int y) external pure returns (uint256);
  function decodetokenid(uint value) external pure returns (int, int);
  function exists(int x, int y) external view returns (bool);
  function ownerofland(int x, int y) external view returns (address);
  function owneroflandmany(int[] x, int[] y) external view returns (address[]);
  function landof(address owner) external view returns (int[], int[]);
  function landdata(int x, int y) external view returns (string);

  
  function transferland(int x, int y, address to) external;
  function transfermanyland(int[] x, int[] y, address to) external;

  
  function updatelanddata(int x, int y, string data) external;
  function updatemanylanddata(int[] x, int[] y, string data) external;

  

  event update(
    uint256 indexed assetid,
    address indexed holder,
    address indexed operator,
    string data
  );

  event updateoperator(
    uint256 indexed assetid,
    address indexed operator
  );

  event deployauthorized(
    address indexed _caller,
    address indexed _deployer
  );

  event deployforbidden(
    address indexed _caller,
    address indexed _deployer
  );
}
