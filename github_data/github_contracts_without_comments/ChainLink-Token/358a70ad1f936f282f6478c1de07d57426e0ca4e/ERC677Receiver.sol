pragma solidity ^0.4.8;


contract erc677receiver {
  function tokenfallback(address _sender, uint _value, bytes _data);
}
