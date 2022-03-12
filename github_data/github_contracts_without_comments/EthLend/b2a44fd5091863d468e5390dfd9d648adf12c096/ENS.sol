pragma solidity ^0.4.11;

contract abstractens {
     function owner(bytes32 node) constant returns(address);
     function resolver(bytes32 node) constant returns(address);
     function ttl(bytes32 node) constant returns(uint64);
     function setowner(bytes32 node, address owner);
     function setsubnodeowner(bytes32 node, bytes32 label, address owner);
     function setresolver(bytes32 node, address resolver);
     function setttl(bytes32 node, uint64 ttl);

     
     event newowner(bytes32 indexed node, bytes32 indexed label, address owner);

     
     event transfer(bytes32 indexed node, address owner);

     
     event newresolver(bytes32 indexed node, address resolver);

     
     event newttl(bytes32 indexed node, uint64 ttl);
}


contract testens is abstractens {
     function owner(bytes32 node) constant returns(address out){
          out = owner_;
          return;
     }

     function setowner(bytes32 node, address o){
          owner_ = o; 
     }
     
     address public owner_;
}