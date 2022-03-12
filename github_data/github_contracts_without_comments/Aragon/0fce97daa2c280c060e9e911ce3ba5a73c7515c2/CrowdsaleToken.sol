pragma solidity ^0.4.8;


import ;



contract crowdsaletoken is standardtoken {

  string public name = ;
  string public symbol = ;
  uint public decimals = 18;

  
  uint price = 500;

  function () payable {
    createtokens(msg.sender);
  }
  
  function createtokens(address recipient) payable {
    if (msg.value == 0) {
      throw;
    }

    uint tokens = safemul(msg.value, getprice());

    totalsupply = safeadd(totalsupply, tokens);
    balances[recipient] = safeadd(balances[recipient], tokens);
  }
  
  
  function getprice() constant returns (uint result) {
    return price;
  }
}
