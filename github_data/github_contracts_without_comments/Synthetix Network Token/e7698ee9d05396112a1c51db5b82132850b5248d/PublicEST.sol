pragma solidity ^0.4.23;

import ;

contract publicest is externstatetoken {
    uint constant decimals = 18;

    constructor(address _proxy, tokenstate _tokenstate,
                string _name, string _symbol, uint _totalsupply,
                address _owner)
        externstatetoken(_proxy, _tokenstate, _name, _symbol, _totalsupply, decimals, _owner)
        public
    {}

    function transfer(address to, uint value)
        optionalproxy
        external
        returns (bool)
    {
        bytes memory empty;
        return _transfer_byproxy(messagesender, to, value, empty);
    }

    function transfer(address to, uint value, bytes data)
        optionalproxy
        external
        returns (bool)
    {
        return _transfer_byproxy(messagesender, to, value, data);
    }

    function transferfrom(address from, address to, uint value)
        optionalproxy
        external
        returns (bool)
    {
        bytes memory empty;
        return _transferfrom_byproxy(messagesender, from, to, value, empty);
    }

    function transferfrom(address from, address to, uint value, bytes data)
        optionalproxy
        external
        returns (bool)
    {
        return _transferfrom_byproxy(messagesender, from, to, value, data);
    }
}
