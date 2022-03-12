pragma solidity ^0.4.18;


import ;
import ;




contract timelockedsafe {

    using safemath for uint;

	uint constant public decimals = 18;

	uint constant public onemonth = 30 days;

    address public withdrawaddress;

    uint public lockingperiodinmonths; 

    uint public vestingperiodinmonths; 
                                       

    uint public monthlywithdrawlimitinwei; 

    thetatoken public token;

    uint public starttime;

    function timelockedsafe(address _withdrawaddress,
    	uint _lockingperiodinmonths, uint _vestingperiodinmonths,
    	uint _monthlywithdrawlimitinwei, address _token) public {
    	require(_withdrawaddress != 0);
    	require(_token != 0);

    	
    	require(_monthlywithdrawlimitinwei > 100 * (10 ** decimals));

    	withdrawaddress = _withdrawaddress;
    	lockingperiodinmonths = _lockingperiodinmonths;
    	vestingperiodinmonths = _vestingperiodinmonths;
    	monthlywithdrawlimitinwei = _monthlywithdrawlimitinwei;
    	token = thetatoken(_token);
    	starttime = now;
    }

    function withdraw(uint _withdrawamountinwei) public returns (bool) {    	
    	uint timeelapsed = now.sub(starttime);
    	uint monthselapsed = (timeelapsed.div(onemonth)).add(1);
    	require(monthselapsed >= lockingperiodinmonths);

    	uint fullyvestedtimeinmonths = lockingperiodinmonths.add(vestingperiodinmonths);
    	uint remainingvestingperiodinmonths = 0;
    	if (monthselapsed < fullyvestedtimeinmonths) {
    		remainingvestingperiodinmonths = fullyvestedtimeinmonths.sub(monthselapsed);
    	}

    	address timelockedsafeaddress = address(this);
    	uint minimalbalanceinwei = remainingvestingperiodinmonths.mul(monthlywithdrawlimitinwei);
    	uint currenttokenbalanceinwei = token.balanceof(timelockedsafeaddress);
    	require(currenttokenbalanceinwei.sub(_withdrawamountinwei) >= minimalbalanceinwei);

    	require(token.transfer(withdrawaddress, _withdrawamountinwei));

    	return true;
    }

}
