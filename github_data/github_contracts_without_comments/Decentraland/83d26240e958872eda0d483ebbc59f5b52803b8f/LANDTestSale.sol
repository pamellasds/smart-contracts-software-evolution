pragma solidity ^0.4.15;

import ;

contract landtestsale is landtoken {

  function landtestsale() {
    owner = this;
  }

  function buy(uint256 _x, uint256 _y, string _data) public {
    uint token = buildtokenid(_x, _y);
    if (ownerof(token) != 0) {
      _transfer(ownerof(token), msg.sender, token);
      tokenmetadata[token] = _data;
    } else {
      assignnewparcel(msg.sender, token, _data);
    }
  }
}
