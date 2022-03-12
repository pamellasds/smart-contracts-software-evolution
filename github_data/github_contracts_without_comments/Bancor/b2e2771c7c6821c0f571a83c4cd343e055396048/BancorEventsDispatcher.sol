pragma solidity ^0.4.10;
import ;
import ;


contract bancoreventsdispatcher is owned {
    bancoreventsinterface public events;    

    
    function bancoreventsdispatcher(address _events) {
        events = bancoreventsinterface(_events);
    }

    
    function setevents(address _events) public owneronly {
        require(_events != address(events));
        events = bancoreventsinterface(_events);
    }
}
