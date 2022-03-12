pragma solidity ^0.6.0;

import ;

contract linkreceiver {
  bool public fallbackcalled;
  bool public calldatacalled;
  uint public tokensreceived;

  function ontokentransfer(address _from, uint _amount, bytes memory _data) public returns (bool) {
    fallbackcalled = true;
    if (_data.length > 0) {
      (bool success, bytes memory _returndata) = address(this).delegatecall(_data);
      require(success, );
    }
    return true;
  }

  function callbackwithoutwithdrawl() public {
    calldatacalled = true;
  }

  function callbackwithwithdrawl(uint _value, address _from, address _token) public {
    calldatacalled = true;
    ierc20 token = ierc20(_token);
    token.transferfrom(_from, address(this), _value);
    tokensreceived = _value;
  }
}
