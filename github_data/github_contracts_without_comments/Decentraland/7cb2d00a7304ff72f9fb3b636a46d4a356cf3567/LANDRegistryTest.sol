pragma solidity ^0.4.18;

import ;

contract landregistrytest is landregistry {
  function existsproxy(int x, int y) view public returns (bool) {
    return exists(encodetokenid(x, y));
  }
}