pragma solidity ^0.4.8;


contract token677receivermock {
    address public tokensender;
    uint public sentvalue;
    bytes public tokendata;
    bool public calledfallback = false;

    function tokenfallback(address _sender, uint _value, bytes _data)
    public {
      calledfallback = true;

      tokensender = _sender;
      sentvalue = _value;
      tokendata = _data;
    }

}
