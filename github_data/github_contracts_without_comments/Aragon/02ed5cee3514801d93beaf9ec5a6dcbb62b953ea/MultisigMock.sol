pragma solidity ^0.4.8;

import ;

contract multisigmock {
  function activatesale(address sale, address factory) {
    aragontokensale(sale).deployant(factory, true);
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
