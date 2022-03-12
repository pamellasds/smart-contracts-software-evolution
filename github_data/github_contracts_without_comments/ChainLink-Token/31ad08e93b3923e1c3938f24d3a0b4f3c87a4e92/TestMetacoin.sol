pragma solidity ^0.4.2;

import ;
import ;
import ;

contract testmetacoin {

  function testinitialbalanceusingdeployedcontract() {
    metacoin meta = metacoin(deployedaddresses.metacoin());

    uint expected = 10000;

    assert.equal(meta.getbalance(tx.origin), expected, );
  }

  function testinitialbalancewithnewmetacoin() {
    metacoin meta = new metacoin();

    uint expected = 10000;

    assert.equal(meta.getbalance(tx.origin), expected, );
  }

}
