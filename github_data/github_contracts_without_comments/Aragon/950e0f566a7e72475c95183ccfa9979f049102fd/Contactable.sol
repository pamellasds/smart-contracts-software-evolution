pragma solidity ^0.4.0;

import ;

contract contactable is ownable{

     string public contactinformation;

     function setcontactinformation(string info) onlyowner{
         contactinformation = info;
     }

}
