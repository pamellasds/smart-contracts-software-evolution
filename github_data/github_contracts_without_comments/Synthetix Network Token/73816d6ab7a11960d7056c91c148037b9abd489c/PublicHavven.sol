

pragma solidity ^0.4.23;


import ;
import ;



contract publichavven is havven {
    
    uint constant public min_fee_period_duration = 1 days;
    uint constant public max_fee_period_duration = 26 weeks;

    uint constant public max_issuance_ratio = unit;

    constructor(address _proxy, tokenstate _state, address _owner, address _oracle, uint _price, address[] _issuers, havven _oldhavven)
        havven(_proxy, _state, _owner, _oracle, _price, _issuers, _oldhavven)
        public
    {}

     
    function endow(address to, uint value)
        external
        optionalproxy_onlyowner
    {
        address sender = this;
        
        require(nominsissued[sender] == 0 || value <= transferablehavvens(sender));
        
        tokenstate.setbalanceof(sender, safesub(tokenstate.balanceof(sender), value));
        tokenstate.setbalanceof(to, safeadd(tokenstate.balanceof(to), value));
        emittransfer(sender, to, value);
    }

    function setfeeperiodstarttime(uint value)
        external
        optionalproxy_onlyowner
    {
        feeperiodstarttime = value;
    }

    function setlastfeeperiodstarttime(uint value)
        external
        optionalproxy_onlyowner
    {
        lastfeeperiodstarttime = value;
    }

    function settotalissuancedata(uint cbs, uint lab, uint lm)
        external
        optionalproxy_onlyowner
    {
        totalissuancedata.currentbalancesum = cbs;
        totalissuancedata.lastaveragebalance = lab;
        totalissuancedata.lastmodified = lm;
    }
    
    function setissuancedata(address account, uint cbs, uint lab, uint lm)
        external
        optionalproxy_onlyowner
    {
        issuancedata[account].currentbalancesum = cbs;
        issuancedata[account].lastaveragebalance = lab;
        issuancedata[account].lastmodified = lm;
    }

    function setnominsissued(address account, uint value)
        external
        optionalproxy_onlyowner
    {
        nominsissued[account] = value;
    }

    function currenttime()
        public
        returns (uint)
    {
        return now;
    }
}
