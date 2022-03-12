pragma solidity ^0.6.0;

abstract contract erc677receiver {
  function ontokentransfer(address _sender, uint _value, bytes memory _data) public virtual;
}
