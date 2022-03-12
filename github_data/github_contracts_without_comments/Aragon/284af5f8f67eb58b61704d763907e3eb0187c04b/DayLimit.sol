pragma solidity ^0.4.8;


import ;



contract daylimit {

  uint public dailylimit;
  uint public spenttoday;
  uint public lastday;


  function daylimit(uint _limit) {
    dailylimit = _limit;
    lastday = today();
  }

  
  function _setdailylimit(uint _newlimit) internal {
    dailylimit = _newlimit;
  }

  
  function _resetspenttoday() internal {
    spenttoday = 0;
  }

  
  
  function underlimit(uint _value) internal returns (bool) {
    
    if (today() > lastday) {
      spenttoday = 0;
      lastday = today();
    }
    
    
    if (spenttoday + _value >= spenttoday && spenttoday + _value <= dailylimit) {
      spenttoday += _value;
      return true;
    }
    return false;
  }

  
  function today() private constant returns (uint) {
    return now / 1 days;
  }


  
  modifier limiteddaily(uint _value) {
    if (!underlimit(_value)) {
      throw;
    }
    _;
  }
}
