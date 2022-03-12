
pragma solidity ^0.4.19;

import ;

contract publicethernomin is ethernomin {

	function publicethernomin(havven _havven, address _oracle,
                              address _beneficiary,
                              uint initialetherprice,
                              address _owner)
		ethernomin(_havven, _oracle, _beneficiary, initialetherprice, _owner)
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

	function debugwithdrawallether(address recipient)
		public
	{
		recipient.send(this.balance);
	}
	
	function debugemptyfeepool()
		public
	{
		feepool = 0;
	}

	function debugfreezeaccount(address target)
		public
	{
		isfrozen[target] = true;
	}
}
