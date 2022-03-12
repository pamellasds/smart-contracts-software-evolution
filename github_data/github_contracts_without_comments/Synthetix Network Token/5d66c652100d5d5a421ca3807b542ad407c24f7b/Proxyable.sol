pragma solidity ^0.5.16;


import ;


import ;



contract proxyable is owned {
    

    
    proxy public proxy;
    proxy public integrationproxy;

    
    address public messagesender;

    constructor(address payable _proxy) internal {
        
        require(owner != address(0), );

        proxy = proxy(_proxy);
        emit proxyupdated(_proxy);
    }

    function setproxy(address payable _proxy) external onlyowner {
        proxy = proxy(_proxy);
        emit proxyupdated(_proxy);
    }

    function setintegrationproxy(address payable _integrationproxy) external onlyowner {
        integrationproxy = proxy(_integrationproxy);
    }

    function setmessagesender(address sender) external onlyproxy {
        messagesender = sender;
    }

    modifier onlyproxy {
        _onlyproxy();
        _;
    }

    function _onlyproxy() private view {
        require(proxy(msg.sender) == proxy || proxy(msg.sender) == integrationproxy, );
    }

    modifier optionalproxy {
        _optionalproxy();
        _;
    }

    function _optionalproxy() private {
        if (proxy(msg.sender) != proxy && proxy(msg.sender) != integrationproxy && messagesender != msg.sender) {
            messagesender = msg.sender;
        }
    }

    modifier optionalproxy_onlyowner {
        _optionalproxy_onlyowner();
        _;
    }

    function _optionalproxy_onlyowner() private {
        if (proxy(msg.sender) != proxy && proxy(msg.sender) != integrationproxy && messagesender != msg.sender) {
            messagesender = msg.sender;
        }
        require(messagesender == owner, );
    }

    event proxyupdated(address proxyaddress);
}
