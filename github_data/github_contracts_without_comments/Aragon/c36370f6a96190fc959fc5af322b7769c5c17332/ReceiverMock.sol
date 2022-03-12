pragma solidity ^0.4.8;

import ;

contract receivermock is examplereceiver {
  uint public sentvalue;
  address public tokenaddr;
  address public tokensender;
  bool public calledfoo;

  bytes public tokendata;
  bytes4 public tokensig;

  function foo() tokenpayable {
    savetokenvalues();
    calledfoo = true;
  }

  function () tokenpayable {
    savetokenvalues();
  }

  function savetokenvalues() private {
    tokenaddr = tkn.addr;
    tokensender = tkn.sender;
    sentvalue = tkn.value;
    tokensig = tkn.sig;
    tokendata = tkn.data;
  }
}
