pragma solidity ^0.4.8;

import ;




contract aragontokensaletokenmock is aragontokensalemock {
  function aragontokensaletokenmock(address initialaccount, uint initialbalance)
    aragontokensalemock(10, 20, msg.sender, msg.sender, 100, 50, 2)
    {
    deployant(new minimetokenfactory(), true);
    allocatepresaletokens(initialaccount, initialbalance, uint64(now), uint64(now));
    activatesale();
    setmockedblocknumber(21);
    finalizesale();
  }
}
