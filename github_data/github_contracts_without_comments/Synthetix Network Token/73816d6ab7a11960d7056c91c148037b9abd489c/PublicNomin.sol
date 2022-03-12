
pragma solidity ^0.4.23;


import ;
import ;


contract publicnomin is nomin {

    uint constant max_transfer_fee_rate = unit;  

    constructor(address _proxy, tokenstate _tokenstate, havven _havven,
                uint _totalsupply,
                address _owner)
        nomin(_proxy, _tokenstate, _havven, _totalsupply, _owner)
        public {}
    
    function debugemptyfeepool()
        public
    {
        tokenstate.setbalanceof(fee_address, 0);
    }

    function debugfreezeaccount(address target)
        optionalproxy
        public
    {
        require(!frozen[target]);
        uint balance = tokenstate.balanceof(target);
        tokenstate.setbalanceof(fee_address, safeadd(tokenstate.balanceof(fee_address), balance));
        tokenstate.setbalanceof(target, 0);
        frozen[target] = true;
        emitaccountfrozen(target, balance);
        emittransfer(target, fee_address, balance);
    }

    function givenomins(address account, uint amount)
        optionalproxy
        public
    {
        tokenstate.setbalanceof(account, safeadd(amount, tokenstate.balanceof(account)));
        totalsupply = safeadd(totalsupply, amount);
    }

    function clearnomins(address account)
        optionalproxy
        public
    {
        totalsupply = safesub(totalsupply, tokenstate.balanceof(account));
        tokenstate.setbalanceof(account, 0);
    }

    function generatefees(uint amount)
        optionalproxy
        public
    {
        totalsupply = safeadd(totalsupply, amount);
        tokenstate.setbalanceof(fee_address, safeadd(balanceof(fee_address), amount));
    }

    
    function publicissue(address target, uint amount)
        public
    {
        tokenstate.setbalanceof(target, safeadd(tokenstate.balanceof(target), amount));
        totalsupply = safeadd(totalsupply, amount);
        emittransfer(address(0), target, amount);
        emitissued(target, amount);
    }

    
    function publicburn(address target, uint amount)
        public
    {
        tokenstate.setbalanceof(target, safesub(tokenstate.balanceof(target), amount));
        totalsupply = safesub(totalsupply, amount);
        emittransfer(target, address(0), amount);
        emitburned(target, amount);
    }
}
