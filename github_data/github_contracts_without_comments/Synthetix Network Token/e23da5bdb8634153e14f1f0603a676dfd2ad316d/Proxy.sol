




pragma solidity ^0.4.20;

import ;

contract proxy is owned {
    proxyable target;
    bool public metropolis;

    function proxy(proxyable _target, address _owner)
        owned(_owner)
        public
    {
        target = _target;
        targetchanged(_target);
    }

    function _settarget(address _target) 
        external
        onlyowner
    {
        require(_target != address(0));
        target = proxyable(_target);
        targetchanged(_target);
    }

    
    function _setmetropolis(bool _metropolis)
        external
        onlyowner
    {
        metropolis = _metropolis;
    }

    function () 
        public
        payable
    {
        target.setmessagesender(msg.sender);
        assembly {
            
            let free_ptr := mload(0x40)
            calldatacopy(free_ptr, 0, calldatasize)

            
            let met_cond := sload(metropolis_slot)
            if met_cond
            {
                
                let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
                returndatacopy(free_ptr, 0, returndatasize)

                
                if iszero(result) { revert(free_ptr, calldatasize) }
                return(free_ptr, returndatasize)
            }
            
            let ret_size := 32
            let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, free_ptr, ret_size)
            if iszero(result) { revert(free_ptr, calldatasize) }
            return(free_ptr, ret_size)
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
        proxychanged(_proxy);
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

    modifier onlyowner_proxy
    {
        require(messagesender == owner);
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
