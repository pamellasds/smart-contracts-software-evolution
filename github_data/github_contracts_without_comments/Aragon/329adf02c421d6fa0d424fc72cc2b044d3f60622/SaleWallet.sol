pragma solidity ^0.4.8;






contract salewallet {
  
  address public multisig;
  uint public finalblock;

  
  
  
  function salewallet(address _multisig, uint _finalblock) {
    multisig = _multisig;
    finalblock = _finalblock;
  }

  
  function () payable {}

  
  function withdraw() {
    if (msg.sender != multisig) throw;        
    if (block.number < finalblock) throw;     
    suicide(multisig);                        
  }
}
