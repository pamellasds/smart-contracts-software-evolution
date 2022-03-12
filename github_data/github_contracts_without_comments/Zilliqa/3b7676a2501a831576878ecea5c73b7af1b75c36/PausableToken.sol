pragma solidity ^0.4.18;

import ;
import ;



contract pausabletoken is standardtoken, pausable {

  function transfer(address _to, uint256 _value) public whennotpaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferfrom(address _from, address _to, uint256 _value) public whennotpaused returns (bool) {
    return super.transferfrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whennotpaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseapproval(address _spender, uint _addedvalue) public whennotpaused returns (bool success) {
    return super.increaseapproval(_spender, _addedvalue);
  }

  function decreaseapproval(address _spender, uint _subtractedvalue) public whennotpaused returns (bool success) {
    return super.decreaseapproval(_spender, _subtractedvalue);
  }
}
