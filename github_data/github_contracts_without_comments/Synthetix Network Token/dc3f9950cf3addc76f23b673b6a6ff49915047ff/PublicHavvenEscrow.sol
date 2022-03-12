
pragma solidity ^0.4.23;


import ;
import ;

contract publichavvenescrow is havvenescrow {
    using safemath for uint;

    constructor(address _owner, havven _havven)
		havvenescrow(_owner, _havven)
		public 
	{
		
        setupexpirytime = now + 50000 weeks;
    }

    function addregularvestingschedule(address account, uint conclusiontime, uint totalquantity, uint vestingperiods)
        external
        onlyowner
        onlyduringsetup
    {
        
        uint totalduration = conclusiontime.sub(now);

        
        uint periodquantity = totalquantity.div(vestingperiods);
        uint periodduration = totalduration.div(vestingperiods);

        
        for (uint i = 1; i < vestingperiods; i++) {
            uint periodconclusiontime = now.add(i.mul(periodduration));
            appendvestingentry(account, periodconclusiontime, periodquantity);
        }

        
        uint finalperiodquantity = totalquantity.sub(periodquantity.mul(vestingperiods  1));
        appendvestingentry(account, conclusiontime, finalperiodquantity);
    }
}
