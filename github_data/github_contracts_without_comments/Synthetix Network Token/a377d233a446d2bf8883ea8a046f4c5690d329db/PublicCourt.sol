pragma solidity ^0.4.23;


import ;


contract publiccourt is court {

    constructor(havven _havven, nomin _nomin, address _owner)
        court(_havven, _nomin, _owner)
        public
    {}

    function _havven()
        public
        view
        returns (address)
    {
        return havven;
    }

    function _nomin()
        public
        view
        returns (address)
    {
        return nomin;
    }

    function _nextmotionid()
        public
        view
        returns (uint)
    {
        return nextmotionid;
    }

    function _min_voting_period()
        public
        view
        returns (uint)
    {
        return min_voting_period;
    }

    function _max_voting_period()
        public
        view
        returns (uint)
    {
        return max_voting_period;
    }

    function _min_confirmation_period()
        public
        view
        returns (uint)
    {
        return min_confirmation_period;
    }

    function _max_confirmation_period()
        public
        view
        returns (uint)
    {
        return max_confirmation_period;
    }

    function _min_required_participation()
        public
        view
        returns (uint)
    {
        return min_required_participation;
    }

    function _min_required_majority()
        public
        view
        returns (uint)
    {
        return min_required_majority;
    }

    function _voteweight(address account, uint motionid)
        public
        view
        returns (uint)
    {
        return voteweight[account][motionid];
    }

    function publicsetupvote(uint voteindex)
        public
        returns (uint)
    {
        uint weight = setupvote(voteindex);
        emit setupvotereturnvalue(weight);
        return weight;
    }

    event setupvotereturnvalue(uint value);
}
