pragma solidity ^0.4.11;

contract abstractens {
     function owner(bytes32) constant returns(address){ 
          return 0;
     }

     function resolver(bytes32) constant returns(address){ 
          return 0;
     }

     function ttl(bytes32) constant returns(uint64){ 
          return 0;
     }
     function setowner(bytes32, address){

     }

     function setsubnodeowner(bytes32, bytes32, address){

     }

     function setresolver(bytes32, address){

     }

     function setttl(bytes32, uint64){
          
     }

     
     event newowner(bytes32 indexed node, bytes32 indexed label, address owner);

     
     event transfer(bytes32 indexed node, address owner);

     
     event newresolver(bytes32 indexed node, address resolver);

     
     event newttl(bytes32 indexed node, uint64 ttl);
}

contract testens is abstractens {

     mapping (bytes32 => address) hashtoowner;

     function owner(bytes32 node) constant returns(address out){
          out = hashtoowner[node];
          return;
     }

     function setowner(bytes32 node, address o){
          hashtoowner[node] = o;
     } 
}
