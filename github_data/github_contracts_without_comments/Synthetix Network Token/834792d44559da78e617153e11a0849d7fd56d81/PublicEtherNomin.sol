
pragma solidity ^0.4.19;

import ;

contract publicethernomin is ethernomin {

	function publicethernomin(havven _havven, address _oracle,
                              address _beneficiary,
                              uint initialetherprice,
                              address _owner)
		ethernomin(_havven, _oracle, _beneficiary, initialetherprice, _owner)
		public {}
     
	function publiclastpriceupdate()
		view
		public
		returns (uint)
	{
		return lastpriceupdate;
	}

	function publicstaleperiod()
		view
		public
		returns (uint)
	{
    	return staleperiod;
	}

	function debugwithdrawallether(address recipient)
		public
	{
		recipient.send(this.balance);
	}
}
