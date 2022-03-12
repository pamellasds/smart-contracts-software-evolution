

pragma solidity 0.4.25;

import ;
import ;



contract proxyable is owned {
    
    proxy public proxy;
    proxy public integrationproxy;

    
    address public messagesender;

    constructor(address _proxy, address _owner) public owned(_owner) {
        proxy = proxy(_proxy);
        emit proxyupdated(_proxy);
    }

    function setproxy(address _proxy) external onlyowner {
        proxy = proxy(_proxy);
        emit proxyupdated(_proxy);
    }

    function setintegrationproxy(address _integrationproxy) external onlyowner {
        integrationproxy = proxy(_integrationproxy);
    }

    function setmessagesender(address sender) external onlyproxy {
        messagesender = sender;
    }

    modifier onlyproxy {
        require(proxy(msg.sender) == proxy || proxy(msg.sender) == integrationproxy, );
        _;
    }

    modifier optionalproxy {
        if (proxy(msg.sender) != proxy && proxy(msg.sender) != integrationproxy && messagesender != msg.sender) {
            messagesender = msg.sender;
        }
        _;
    }

    modifier optionalproxy_onlyowner {
        if (proxy(msg.sender) != proxy && proxy(msg.sender) != integrationproxy && messagesender != msg.sender) {
            messagesender = msg.sender;
        }
        require(messagesender == owner, );
        _;
    }

    event proxyupdated(address proxyaddress);
}
