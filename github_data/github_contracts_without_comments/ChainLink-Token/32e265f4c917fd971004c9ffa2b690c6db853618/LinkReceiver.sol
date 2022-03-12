pragma solidity ^0.4.11;


import ;
import ;


contract linkreceiver is erc677receiver {

  bool public callbackcalled;
  bool public calldatacalled;
  uint public tokensreceived;

  function receiveapproval(
    address _from, uint256 _amount, address _token, bytes _data)
  public returns (bool _success)
  {
    callbackcalled = true;
    if (_data.length > 0) {
      require(this.call(_data));
    }
    return true;
  }


  function callbackwithoutwithdrawl()
  public
  {
    calldatacalled = true;
  }

  function callbackwithwithdrawl(uint _value, address _from, address _token)
  public
  {
    calldatacalled = true;
    erc20 token = erc20(_token);
    token.transferfrom(_from, this, _value);
    tokensreceived = _value;
  }


}
