pragma solidity ^0.4.15;

import ;

contract landtestsale {

  landtoken public land;

  function landtestsale(address _land) {
    land = landtoken(_land);
  }

  function buy(uint256 _x, uint256 _y, string _data) public {
    uint token = land.buildtokenid(_x, _y);
    if (land.exists(token)) {
      land._transfer(land.ownerof(token), msg.sender, token);
    } else {
      land.assignnewparcel(msg.sender, token, _data);
    }
  }

  function claimforgottenparcel(address beneficiary, uint tokenid) public {
    land.claimforgottenparcel(beneficiary, tokenid);
  }
}
