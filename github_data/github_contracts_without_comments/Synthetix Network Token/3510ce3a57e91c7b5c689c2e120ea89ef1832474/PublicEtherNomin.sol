
pragma solidity ^0.4.21;


import ;
import ;


contract publicethernomin is ethernomin {

    function publicethernomin(address _havven, address _oracle,
                              address _beneficiary,
                              uint initialetherprice,
                              address _owner, tokenstate initialstate)
        ethernomin(_havven, _oracle, _beneficiary, initialetherprice, _owner, initialstate)
        public {}

    function publicethervalueallowstale(uint n) 
        public
        view
        returns (uint)
    {
        return ethervalueallowstale(n);
    }

    function publicsaleproceedsetherallowstale(uint n)
        public
        view
        returns (uint)
    {
        return saleproceedsetherallowstale(n);
    }

    function currenttime()
        public
        returns (uint)
    {
        return now;
    }

    function debugwithdrawallether(address recipient)
        public
    {
        recipient.transfer(balanceof(this));
    }
    
    function debugemptyfeepool()
        public
    {
        state.setbalanceof(address(this), 0);
    }

    function debugfreezeaccount(address target)
        public
    {
        frozen[target] = true;
    }
}
