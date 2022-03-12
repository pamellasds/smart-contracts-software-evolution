pragma solidity ^0.4.8;

import ;

contract multisigmock {
  function deployandsetant(address sale) {
    ant token = new ant(new minimetokenfactory());
    anplaceholder networkplaceholder = new anplaceholder(sale, token);
    token.changecontroller(address(sale));

    aragontokensale s = aragontokensale(sale);
    s.setant(token, networkplaceholder, new salewallet(s.aragondevmultisig(), s.finalblock()));
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
    finalizesale(sale, aragontokensalemock(sale).mock_hiddencap());
  }

  function finalizesale(address sale, uint256 cap) {
    aragontokensale(sale).finalizesale(cap, aragontokensalemock(sale).mock_capsecret());
  }

  function deploynetwork(address sale, address network) {
    aragontokensale(sale).deploynetwork(network);
  }

  function () payable {}
}
