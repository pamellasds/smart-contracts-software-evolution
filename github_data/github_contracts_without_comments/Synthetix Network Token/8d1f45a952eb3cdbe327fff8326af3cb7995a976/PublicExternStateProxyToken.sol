pragma solidity ^0.4.20;

import ;
import ;

contract publicexternstateproxytoken is externstateproxytoken {
    function publicexternstateproxytoken(string _name, string _symbol,
                                         uint initialsupply, address initialbeneficiary,
                                         tokenstate _state, address _owner)
        externstateproxytoken(_name, _symbol, initialsupply, initialbeneficiary, _state, _owner)
        public {}

    function transfer_byproxy(address to, uint value) 
        public
        optionalproxy
        returns (bool)
    {
        return _transfer_byproxy(messagesender, to, value);
    }

    function transferfrom_byproxy(address from, address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        return _transferfrom_byproxy(messagesender, from, to, value);
    }

    function _messagesender()
        public
        returns (address)
    {
        return messagesender;
    }

    function _optionalproxy_tester()
        public
        optionalproxy
        returns (address)
    {
        return messagesender;
    }
}
