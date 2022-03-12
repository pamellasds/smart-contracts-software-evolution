pragma solidity ^0.4.18;

interface ilandregistry {

  
  function assignnewparcel(int x, int y, address beneficiary) public;
  function assignmultipleparcels(int[] x, int[] y, address beneficiary) public;

  
  function ping() public;

  
  function encodetokenid(int x, int y) view public returns (uint256);
  function decodetokenid(uint value) view public returns (int, int);
  function exists(int x, int y) view public returns (bool);
  function ownerofland(int x, int y) view public returns (address);
  function owneroflandmany(int[] x, int[] y) view public returns (address[]);
  function landof(address owner) view public returns (int[], int[]);
  function landdata(int x, int y) view public returns (string);

  
  function transferland(int x, int y, address to) public;
  function transfermanyland(int[] x, int[] y, address to) public;

  
  function updatelanddata(int x, int y, string data) public;
  function updatemanylanddata(int[] x, int[] y, string data) public;

  

  event update(  
    uint256 indexed assetid, 
    address indexed holder,  
    address indexed operator,  
    string data  
  );
}
