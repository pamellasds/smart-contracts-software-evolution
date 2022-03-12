pragma solidity ^0.4.18;


import ;
import ;




contract timelockedsafe {

	uint constant public decimals = 18;

    using safemath for uint;

    address public withdrawaddress;

    uint public maximumbalanceinwei;

    uint public cliffinmonths; 

    uint public monthlywithdrawlimitinwei; 

    thetatoken public token;

    uint public starttime;

    function timelockedsafe(address _withdrawaddress, 
    	uint _maximumbalanceinwei, uint _cliffinmonths, 
    	uint _monthlywithdrawlimitinwei, address _token) public {

    	
    	require(_maximumbalanceinwei > 10000 * (10 ** decimals));
    	require(_monthlywithdrawlimitinwei > 100 * (10 ** decimals));

    	withdrawaddress = _withdrawaddress;
    	maximumbalanceinwei = _maximumbalanceinwei;
    	cliffinmonths = _cliffinmonths;
    	monthlywithdrawlimitinwei = _monthlywithdrawlimitinwei;
    	token = thetatoken(address);
    	starttime = now;
    }

    function withdraw(uint amountinwei) returns (bool) public {
    	uint onemonth = 30 days;
    	uint timeelapsed = now.sub(starttime);
    	uint monthselapsed = timeelapsed.div(onemonth);
    	uint vestingmonth = monthselapsed.sub(cliffinmonths).add(1);
    	require(vestingmonth >= 0);

    	address timelockedsafeaddress = address(this);
    	uint withdrawlimit = monthlywithdrawlimitinwei.mul(vestingmonth);
    	uint minimumbalanceinwei = maximumbalanceinwei.sub(withdrawlimit);
    	uint currenttokenbalanceinwei = token.balanceof(timelockedsafeaddress);
    	require(currenttokenbalanceinwei.sub(amountinwei) >= minimumbalanceinwei);

    	require(token.transfer(withdrawaddress, amountinwei));

    	return true;
    }

}
