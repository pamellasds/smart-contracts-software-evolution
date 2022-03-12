pragma solidity ^0.4.8;

import ;



contract aragontokensalemock is aragontokensale {

  function aragontokensalemock (
      uint _initialblock,
      uint _finalblock,
      address _aragondevmultisig,
      address _communitymultisig,
      uint256 _initialprice,
      uint256 _finalprice,
      uint8 _pricestages
  ) aragontokensale(_initialblock, _finalblock, _aragondevmultisig, _communitymultisig, _initialprice, _finalprice, _pricestages) {

  }

  function getblocknumber() constant returns (uint) {
    return mockedblocknumber;
  }

  function setmockedblocknumber(uint _b) {
    mockedblocknumber = _b;
  }

  uint mockedblocknumber = 1;
}
