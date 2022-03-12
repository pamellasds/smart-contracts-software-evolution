


pragma solidity 0.4.25;

import ;
import ;


contract proxyable is owned {
    
    proxy public proxy;

     
    address messagesender; 

    constructor(address _proxy, address _owner)
        owned(_owner)
        public
    {
        proxy = proxy(_proxy);
        emit proxyupdated(_proxy);
    }

    function setproxy(address _proxy)
        external
        onlyowner
    {
        proxy = proxy(_proxy);
        emit proxyupdated(_proxy);
    }

    function setmessagesender(address sender)
        external
        onlyproxy
    {
        messagesender = sender;
    }

    modifier onlyproxy {
        require(proxy(msg.sender) == proxy, );
        _;
    }

    modifier optionalproxy
    {
        if (proxy(msg.sender) != proxy) {
            messagesender = msg.sender;
        }
        _;
    }

    modifier optionalproxy_onlyowner
    {
        if (proxy(msg.sender) != proxy) {
            messagesender = msg.sender;
        }
        require(messagesender == owner, );
        _;
    }

    event proxyupdated(address proxyaddress);
}
