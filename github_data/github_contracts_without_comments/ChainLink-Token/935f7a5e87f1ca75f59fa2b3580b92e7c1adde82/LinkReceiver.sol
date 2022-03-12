pragma solidity ^0.4.11;


import ;


contract linkreceiver {

  bool public fallbackcalled;
  bool public calldatacalled;
  uint public tokensreceived;


  function ontokentransfer(address _from, uint _amount, bytes _data)
  public returns (bool success) {
    fallbackcalled = true;
    if (_data.length > 0) {
      require(address(this).delegatecall(_data, msg.sender, _from, _amount));
    }
    return true;
  }

  function callbackwithoutwithdrawl() {
    calldatacalled = true;
  }

  function callbackwithwithdrawl(uint _value, address _from, address _token) {
    calldatacalled = true;
    linkerc20 token = linkerc20(_token);
    token.transferfrom(_from, this, _value);
    tokensreceived = _value;
  }

}
