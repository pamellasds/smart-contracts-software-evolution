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
  ) aragontokensale(_initialblock, _finalblock, _aragondevmultisig, _communitymultisig, _initialprice, _finalprice, _pricestages, computecap(mock_hiddencap, mock_capsecret)) {

  }

  function getblocknumber() internal constant returns (uint) {
    return mock_blocknumber;
  }

  function setmockedblocknumber(uint _b) {
    mock_blocknumber = _b;
  }

  function setmockedtotalcollected(uint _totalcollected) {
    totalcollected = _totalcollected;
  }

  uint mock_blocknumber = 1;

  uint public mock_hiddencap = 100 finney;
  uint public mock_capsecret = 1;
}
