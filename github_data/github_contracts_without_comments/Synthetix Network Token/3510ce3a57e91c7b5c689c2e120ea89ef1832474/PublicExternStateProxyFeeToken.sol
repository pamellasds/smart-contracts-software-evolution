pragma solidity ^0.4.21;

import ;
import ;

contract publicexternstateproxyfeetoken is externstateproxyfeetoken {
    function publicexternstateproxyfeetoken(string _name, string _symbol,
                                            uint _feerate, address _feeauthority,
                                            tokenstate _state, address _owner)
        externstateproxyfeetoken(_name, _symbol, _feerate, _feeauthority, _state, _owner)
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
