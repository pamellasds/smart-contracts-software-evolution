

pragma solidity ^0.4.23;


import ;
import ;



contract publichavven is havven {
    
    uint constant public min_fee_period_duration = 1 days;
    uint constant public max_fee_period_duration = 26 weeks;

    constructor(address _proxy, tokenstate _state, address _owner, address _oracle, uint _price)
        havven(_proxy, _state, _owner, _oracle, _price)
        public
    {}

     
    function endow(address to, uint value)
        external
        optionalproxy_onlyowner
    {
        address sender = this;
        
        require(nominsissued[sender] == 0 || value <= availablehavvens(sender));
        
        tokenstate.setbalanceof(sender, safesub(tokenstate.balanceof(sender), value));
        tokenstate.setbalanceof(to, safeadd(tokenstate.balanceof(to), value));
        emittransfer(sender, to, value);
    }

    function currenttime()
        public
        returns (uint)
    {
        return now;
    }
}
