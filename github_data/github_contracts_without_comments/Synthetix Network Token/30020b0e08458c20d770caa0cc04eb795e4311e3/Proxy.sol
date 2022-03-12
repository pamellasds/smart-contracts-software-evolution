


pragma solidity ^0.4.21;

import ;


contract proxy is owned {
    proxyable public _target;

    
    function proxy(proxyable _initialtarget, address _owner)
        owned(_owner)
        public
    {
        _target = _initialtarget;
        emit targetchanged(_initialtarget);
    }

    
    function _settarget(address newtarget) 
        external
        onlyowner
    {
        require(newtarget != address(0));
        _target = proxyable(newtarget);
        emit targetchanged(newtarget);
    }

    
    function () 
        public
        payable
    {
        _target.setmessagesender(msg.sender);
        assembly {
            
            let free_ptr := mload(0x40)
            calldatacopy(free_ptr, 0, calldatasize)

            
            let result := call(gas, sload(_target_slot), callvalue, free_ptr, calldatasize, 0, 0)
            returndatacopy(free_ptr, 0, returndatasize)

            
            if iszero(result) { revert(free_ptr, calldatasize) }
            return(free_ptr, returndatasize)
        } 
    }

    event targetchanged(address targetaddress);
}



contract proxyable is owned {
    
    proxy public proxy;

    
    address messagesender;

    
    function proxyable(address _owner)
        owned(_owner)
        public { }

    
    function setproxy(proxy _proxy)
        external
        onlyowner
    {
        proxy = _proxy;
        emit proxychanged(_proxy);
    }

    
    function setmessagesender(address sender)
        external
        onlyproxy
    {
        messagesender = sender;
    }

    modifier onlyproxy
    {
        require(proxy(msg.sender) == proxy);
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
        require(messagesender == owner);
        _;
    }

    event proxychanged(address proxyaddress);

}
