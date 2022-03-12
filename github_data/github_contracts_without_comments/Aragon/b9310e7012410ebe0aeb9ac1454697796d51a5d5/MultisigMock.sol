pragma solidity ^0.4.8;

import ;

contract multisigmock {
  function activatesale(address sale, address factory) {
    ant token = new ant(factory);
    anplaceholder networkplaceholder = new anplaceholder(this, token);
    token.changecontroller(address(this));

    aragontokensale(sale).setant(token, networkplaceholder);
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

  function () payable {}
}
