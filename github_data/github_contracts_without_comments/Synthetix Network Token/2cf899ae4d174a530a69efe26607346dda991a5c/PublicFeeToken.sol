pragma solidity ^0.4.23;

import ;

contract publicfeetoken is feetoken {
    constructor(address _proxy, tokenstate _tokenstate,
                string _name, string _symbol, uint _totalsupply,
                uint _transferfeerate,
                address _feeauthority, address _owner)
        feetoken(_proxy, _tokenstate,
                 _name, _symbol, _totalsupply, _transferfeerate,
                 _feeauthority, _owner)
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

    function transfersenderpaysfee(address to, uint value)
        optionalproxy
        external
    {
        _transfersenderpaysfee_byproxy(messagesender, to, value);
    }

    function transferfromsenderpaysfee(address from, address to, uint value)
        optionalproxy
        external
    {
        _transferfromsenderpaysfee_byproxy(messagesender, from, to, value);
    }

    function givetokens(address account, uint amount)
        optionalproxy
        public
    {
        tokenstate.setbalanceof(account, safeadd(amount, tokenstate.balanceof(account)));
        totalsupply = safeadd(totalsupply, amount);
    }

    function cleartokens(address account)
        optionalproxy
        public
    {
        totalsupply = safesub(totalsupply, tokenstate.balanceof(account));
        tokenstate.setbalanceof(account, 0);
    }

}
