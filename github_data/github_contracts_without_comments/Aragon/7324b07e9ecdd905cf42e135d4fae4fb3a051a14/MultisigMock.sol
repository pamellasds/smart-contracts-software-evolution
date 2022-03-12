pragma solidity ^0.4.8;

import ;

contract multisigmock {
  function activatesale(address sale, address factory) {
    ant token = new ant(factory);
    anplaceholder networkplaceholder = new anplaceholder(sale, token);
    token.changecontroller(address(sale));

    aragontokensale(sale).setant(token, networkplaceholder);
    activatesale(sale);
  }

  function activatesale(address sale) {
    aragontokensale(sale).activatesale();
  }

  function emergencystopsale(address sale) {
    aragontokensale(sale).emergencystopsale();
  }

  function restartsale(address sale) {
    aragontokensale(sale).restartsale();
  }

  function finalizesale(address sale) {
    aragontokensale(sale).finalizesale();
  }

  function deploynetwork(address sale, address network) {
    aragontokensale(sale).deploynetwork(network);
  }

  function () payable {}
}
