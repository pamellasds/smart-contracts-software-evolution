

pragma solidity ^0.4.19;


import ;



contract publichavven is havven {
    
    function publichavven(address _owner)
        havven(_owner)
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

    function _minfeeperioddurationseconds()
        public
        view
        returns (uint)
    {
        return minfeeperioddurationseconds;
    }

    function _maxfeeperioddurationseconds()
        public
        view
        returns (uint)
    {
        return maxfeeperioddurationseconds;
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

    function _postcheckfeeperiodrollover()
        postcheckfeeperiodrollover
        public
    {}
}
