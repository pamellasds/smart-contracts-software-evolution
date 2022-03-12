pragma solidity ^0.4.8;

import ;




contract aragontokensaletokenmock is aragontokensale {
  function aragontokensaletokenmock(address initialaccount, uint initialbalance)
    aragontokensale(block.number + 10, block.number + 100, msg.sender, 0xdead, 2, 1, 2)
    {
    deployant(new minimetokenfactory(), true);
    token.generatetokens(initialaccount, initialbalance);
  }
}
