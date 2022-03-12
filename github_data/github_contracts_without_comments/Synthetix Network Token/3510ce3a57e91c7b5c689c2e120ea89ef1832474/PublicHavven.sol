

pragma solidity ^0.4.21;


import ;
import ;



contract publichavven is havven {

    function publichavven(tokenstate initialstate, address _owner)
        havven(initialstate, _owner)
        public
    {}

    function _currentbalancesum(address account)
        public
        view
        returns (uint)
    {
        return currentbalancesum[account];
    }

    function _lasttransfertimestamp(address account)
        public
        view
        returns (uint)
    {
        return lasttransfertimestamp[account];
    }

    function _haswithdrawnlastperiodfees(address account)
        public
        view
        returns (bool)
    {
        return haswithdrawnlastperiodfees[account];
    }

    function _lastfeeperiodstarttime()
        public
        view
        returns (uint)
    {
        return lastfeeperiodstarttime;
    }

    function _penultimatefeeperiodstarttime()
        public
        view
        returns (uint)
    {
        return penultimatefeeperiodstarttime;
    }

    function _min_fee_period_duration_seconds()
        public
        view
        returns (uint)
    {
        return min_fee_period_duration_seconds;
    }

    function _max_fee_period_duration_seconds()
        public
        view
        returns (uint)
    {
        return max_fee_period_duration_seconds;
    }
    
    function _adjustfeeentitlement(address account, uint prebalance)
        public
    {
        return adjustfeeentitlement(account, prebalance);
    }

    function _rolloverfee(address account, uint lasttransfertime, uint prebalance)
        public
    {
        return rolloverfee(account, lasttransfertime, prebalance);
    }

    function _checkfeeperiodrollover()
        public
    {
        checkfeeperiodrollover();
    }
}
