pragma solidity ^0.4.23;

import ;

contract publicest is externstatetoken {
    constructor(address _proxy, tokenstate _tokenstate,
                string _name, string _symbol, uint _totalsupply,
                address _owner)
        externstatetoken(_proxy, _tokenstate, _name, _symbol, _totalsupply, _owner)
        public
    {}

    function transfer(address to, uint value)
        optionalproxy
        external
    {
        _transfer_byproxy(messagesender, to, value);
    }

    function transferfrom(address from, address to, uint value)
        optionalproxy
        external
    {
        _transferfrom_byproxy(messagesender, from, to, value);
    }
}
