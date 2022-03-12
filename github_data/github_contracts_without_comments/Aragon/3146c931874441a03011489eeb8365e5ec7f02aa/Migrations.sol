pragma solidity ^0.4.8;


import ;


contract migrations is ownable {
  uint public lastcompletedmigration;

  function setcompleted(uint completed) onlyowner {
    lastcompletedmigration = completed;
  }

  function upgrade(address newaddress) onlyowner {
    migrations upgraded = migrations(newaddress);
    upgraded.setcompleted(lastcompletedmigration);
  }
}
