pragma solidity ^0.4.8;


contract erc223receiver {
  function tokenfallback(address _sender, uint _value, bytes _data);
}
