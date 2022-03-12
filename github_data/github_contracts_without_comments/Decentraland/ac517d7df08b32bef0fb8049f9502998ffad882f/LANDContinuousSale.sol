pragma solidity ^0.4.15;

import ;
import ;
import ;

contract landcontinuoussale is landsale, ownable {

  
  uint256 public constant land_mana_cost = 1e21;

  function landcontinuoussale(address _token, address _land) {
    token = burnabletoken(_token);
    land = landtoken(_land);
  }

  function buy(uint256 _x, uint256 _y, string _data) public {
    _buyland(_x, _y, _data, msg.sender, msg.sender, land_mana_cost);
  }

  function _isvalidland(uint256 _x, uint256 _y) internal returns (bool) {
    return exists(_x1, _y) || exists(_x+1, _y) || exists(_x, _y1) || exists(_x, _y+1);
  }
}
