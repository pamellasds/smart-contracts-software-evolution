pragma solidity ^0.4.8;

import ;
import ;




contract aragontokensalemock is aragontokensale {
  function aragontokensalemock(address initialaccount, uint initialbalance)
    aragontokensale(block.number + 10, block.number + 100, msg.sender, 0xdead, 1 wei, 2 wei, 2)
    {
    deployant(new minimetokenfactory(), true);
    token.generatetokens(initialaccount, initialbalance);
  }
}
