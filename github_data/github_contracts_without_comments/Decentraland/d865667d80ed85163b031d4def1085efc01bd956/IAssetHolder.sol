pragma solidity ^0.4.18;

interface iassetholder {
  function onassetreceived(
    
    uint256 _assetid,
    address _previousholder,
    address _currentholder,
    bytes   _userdata,
    address _operator,
    bytes   _operatordata
  ) public;
}
