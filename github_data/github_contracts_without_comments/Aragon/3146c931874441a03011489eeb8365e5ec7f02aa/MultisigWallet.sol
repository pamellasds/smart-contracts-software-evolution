pragma solidity ^0.4.8;


import ;
import ;
import ;



contract multisigwallet is multisig, shareable, daylimit {

  struct transaction {
    address to;
    uint value;
    bytes data;
  }

  function multisigwallet(address[] _owners, uint _required, uint _daylimit)       
    shareable(_owners, _required)        
    daylimit(_daylimit) { }

  
  function kill(address _to) onlymanyowners(sha3(msg.data)) external {
    suicide(_to);
  }

  
  function() payable {
    
    if (msg.value > 0)
      deposit(msg.sender, msg.value);
  }

  
  
  
  
  function execute(address _to, uint _value, bytes _data) external onlyowner returns (bytes32 _r) {
    
    if (underlimit(_value)) {
      singletransact(msg.sender, _value, _to, _data);
      
      if (!_to.call.value(_value)(_data)) {
        throw;
      }
      return 0;
    }
    
    _r = sha3(msg.data, block.number);
    if (!confirm(_r) && txs[_r].to == 0) {
      txs[_r].to = _to;
      txs[_r].value = _value;
      txs[_r].data = _data;
      confirmationneeded(_r, msg.sender, _value, _to, _data);
    }
  }

  
  
  function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
    if (txs[_h].to != 0) {
      if (!txs[_h].to.call.value(txs[_h].value)(txs[_h].data)) {
        throw;
      }
      multitransact(msg.sender, _h, txs[_h].value, txs[_h].to, txs[_h].data);
      delete txs[_h];
      return true;
    }
  }

  function setdailylimit(uint _newlimit) onlymanyowners(sha3(msg.data)) external {
    _setdailylimit(_newlimit);
  }

  function resetspenttoday() onlymanyowners(sha3(msg.data)) external {
    _resetspenttoday();
  }


  

  function clearpending() internal {
    uint length = pendingsindex.length;
    for (uint i = 0; i < length; ++i) {
      delete txs[pendingsindex[i]];
    }
    super.clearpending();
  }


  

  
  mapping (bytes32 => transaction) txs;
}
