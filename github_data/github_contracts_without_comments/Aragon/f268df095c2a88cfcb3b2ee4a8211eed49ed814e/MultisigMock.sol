pragma solidity ^0.4.8;

import ;

contract multisigmock {
  function deployandsetant(address sale) {
    ant token = new ant(new minimetokenfactory());
    anplaceholder networkplaceholder = new anplaceholder(sale, token);
    token.changecontroller(address(sale));

    aragontokensale(sale).setant(token, networkplaceholder);
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
