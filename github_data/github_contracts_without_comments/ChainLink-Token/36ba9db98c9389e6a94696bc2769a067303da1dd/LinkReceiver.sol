pragma solidity ^0.4.11;


import ;


contract linkreceiver {

  bool public fallbackcalled;
  bool public calldatacalled;
  uint public tokensreceived;
  uint public lasttransferamount;
  address public lasttransfersender;


  function tokenfallback(address _from, uint _amount, bytes _data)
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

  function callbackwithoutwithdrawl(address _token, address _from, uint _amount) {
    calldatacalled = true;
  }

  function callbackwithwithdrawl(uint _value, address _from, address _token) {
    calldatacalled = true;
    erc20 token = erc20(_token);
    token.transferfrom(_from, this, _value);
    tokensreceived = _value;
  }

}
