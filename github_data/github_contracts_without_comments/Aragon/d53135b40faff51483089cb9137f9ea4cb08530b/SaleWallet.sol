pragma solidity ^0.4.8;






contract abstractsale {
  function salefinalized() constant returns (bool);
}

contract salewallet {
  
  address public multisig;
  uint public finalblock;
  abstractsale public tokensale;

  
  
  
  function salewallet(address _multisig, uint _finalblock, address _tokensale) {
    multisig = _multisig;
    finalblock = _finalblock;
    tokensale = abstractsale(_tokensale);
  }

  
  function () public payable {}

  
  function withdraw() public {
    if (msg.sender != multisig) throw;                       
    if (block.number > finalblock) return dowithdraw();      
    if (tokensale.salefinalized()) return dowithdraw();      
  }

  function dowithdraw() internal {
    suicide(multisig);
  }
}
