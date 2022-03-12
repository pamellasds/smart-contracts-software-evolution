pragma solidity ^0.4.18;


import ;





contract token {
    
    function balanceof(address _owner) public constant returns (uint balance);
    
    function transfer(address _to, uint _value) public returns (bool success);
}


contract timelockedsafe {

    using safemath for uint;

	uint constant public decimals = 18;

	uint constant public onemonth = 30 days;

    address public adminaddress;

    address public withdrawaddress;

    uint public lockingperiodinmonths; 

    uint public vestingperiodinmonths; 
                                       

    uint public monthlywithdrawlimitinwei; 

    token public token;

    uint public starttime;

    function timelockedsafe(address _adminaddress, address _withdrawaddress,
    	uint _lockingperiodinmonths, uint _vestingperiodinmonths,
    	uint _monthlywithdrawlimitinwei, address _token) public {
        require(_adminaddress != 0);
    	require(_withdrawaddress != 0);

    	
    	require(_monthlywithdrawlimitinwei > 100 * (10 ** decimals));

        adminaddress = _adminaddress;
    	withdrawaddress = _withdrawaddress;
    	lockingperiodinmonths = _lockingperiodinmonths;
    	vestingperiodinmonths = _vestingperiodinmonths;
    	monthlywithdrawlimitinwei = _monthlywithdrawlimitinwei;
    	token = token(_token);
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

    function changestarttime(uint _newstarttime) public only(adminaddress) {
        starttime = _newstarttime;
    }

    function changetokenaddress(address _newtokenaddress) public only(adminaddress) {
        token = token(_newtokenaddress);
    }

    function changewithdrawaddress(address _newwithdrawaddress) public only(adminaddress) {
        withdrawaddress = _newwithdrawaddress;
    }

    function changelockingperiod(uint _newlockingperiodinmonths) public only(adminaddress) {
        lockingperiodinmonths = _newlockingperiodinmonths;
    }

    function changevestingperiod(uint _newvestingperiodinmonths) public only(adminaddress) {
        vestingperiodinmonths = _newvestingperiodinmonths;
    }

    function changemonthlywithdrawlimit(uint _newmonthlywithdrawlimitinwei) public only(adminaddress) {
        monthlywithdrawlimitinwei = _newmonthlywithdrawlimitinwei;
    }

    function finalizeconfig() public only(adminaddress) {
        adminaddress = 0x0; 
    }

    modifier only(address x) {
        require(msg.sender == x);
        _;
    }

}
