pragma solidity ^0.4.19;

import ;

contract publiccourt is court {

	function publiccourt(havven _havven, ethernomin _nomin, address _owner)
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

	function _minvotingperiod()
		public
		view
		returns (uint)
	{
		return minvotingperiod;
	}

	function _maxvotingperiod()
		public
		view
		returns (uint)
	{
		return maxvotingperiod;
	}

	function _minconfirmationperiod()
		public
		view
		returns (uint)
	{
		return minconfirmationperiod;
	}

	function _maxconfirmationperiod()
		public
		view
		returns (uint)
	{
		return maxconfirmationperiod;
	}

	function _minrequiredparticipation()
		public
		view
		returns (uint)
	{
		return minrequiredparticipation;
	}

	function _minrequiredmajority()
		public
		view
		returns (uint)
	{
		return minrequiredmajority;
	}

	function _voteweight(address account)
		public
		view
		returns (uint)
	{
		return voteweight[account];
	}

	function publicsetvotedyea(address account, address target)
		public
	{
		setvotedyea(account, target);
	}

	function publicsetvotednay(address account, address target)
		public
	{
		setvotednay(account, target);
	}
}