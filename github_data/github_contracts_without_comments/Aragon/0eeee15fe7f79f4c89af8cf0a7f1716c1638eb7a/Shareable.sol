pragma solidity ^0.4.8;



contract shareable {
  
  struct pendingstate {
    uint yetneeded;
    uint ownersdone;
    uint index;
  }

  
  uint public required;

  
  uint[256] owners;
  
  mapping(uint => uint) ownerindex;
  
  mapping(bytes32 => pendingstate) pendings;
  bytes32[] pendingsindex;


  
  
  event confirmation(address owner, bytes32 operation);
  event revoke(address owner, bytes32 operation);


  
  modifier onlyowner {
    if (!isowner(msg.sender)) {
      throw;
    }
    _;
  }

  
  
  
  modifier onlymanyowners(bytes32 _operation) {
    if (confirmandcheck(_operation)) {
      _;
    }
  }

  
  
  function shareable(address[] _owners, uint _required) {
    owners[1] = uint(msg.sender);
    ownerindex[uint(msg.sender)] = 1;
    for (uint i = 0; i < _owners.length; ++i) {
      owners[2 + i] = uint(_owners[i]);
      ownerindex[uint(_owners[i])] = 2 + i;
    }
    required = _required;
  }

  
  function revoke(bytes32 _operation) external {
    uint index = ownerindex[uint(msg.sender)];
    
    if (index == 0) {
      return;
    }
    uint ownerindexbit = 2**index;
    var pending = pendings[_operation];
    if (pending.ownersdone & ownerindexbit > 0) {
      pending.yetneeded++;
      pending.ownersdone = ownerindexbit;
      revoke(msg.sender, _operation);
    }
  }

  
  function getowner(uint ownerindex) external constant returns (address) {
    return address(owners[ownerindex + 1]);
  }

  function isowner(address _addr) constant returns (bool) {
    return ownerindex[uint(_addr)] > 0;
  }

  function hasconfirmed(bytes32 _operation, address _owner) constant returns (bool) {
    var pending = pendings[_operation];
    uint index = ownerindex[uint(_owner)];

    
    if (index == 0) {
      return false;
    }

    
    uint ownerindexbit = 2**index;
    return !(pending.ownersdone & ownerindexbit == 0);
  }

  function confirmandcheck(bytes32 _operation) internal returns (bool) {
    
    uint index = ownerindex[uint(msg.sender)];
    
    if (index == 0) {
      return;
    }

    var pending = pendings[_operation];
    
    if (pending.yetneeded == 0) {
      
      pending.yetneeded = required;
      
      pending.ownersdone = 0;
      pending.index = pendingsindex.length++;
      pendingsindex[pending.index] = _operation;
    }
    
    uint ownerindexbit = 2**index;
    
    if (pending.ownersdone & ownerindexbit == 0) {
      confirmation(msg.sender, _operation);
      
      if (pending.yetneeded <= 1) {
        
        delete pendingsindex[pendings[_operation].index];
        delete pendings[_operation];
        return true;
      } else {
        
        pending.yetneeded;
        pending.ownersdone |= ownerindexbit;
      }
    }
  }

  function clearpending() internal {
    uint length = pendingsindex.length;
    for (uint i = 0; i < length; ++i) {
      if (pendingsindex[i] != 0) {
        delete pendings[pendingsindex[i]];
      }
    }
    delete pendingsindex;
  }

}
