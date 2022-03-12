
pragma solidity ^0.4.23;


import ;
import ;


contract publichavvenescrow is havvenescrow {

	constructor(address _owner, havven _havven)
		havvenescrow(_owner, _havven)
		public 
	{
		
		setupexpirytime = now + 50000 weeks;
	}

    function addregularvestingschedule(address account, uint conclusiontime,
                                       uint totalquantity, uint vestingperiods)
        external
        onlyowner
        onlyduringsetup
    {
        
        uint totalduration = safesub(conclusiontime, now);

        
        uint periodquantity = safediv(totalquantity, vestingperiods);
        uint periodduration = safediv(totalduration, vestingperiods);

        
        for (uint i = 1; i < vestingperiods; i++) {
            uint periodconclusiontime = safeadd(now, safemul(i, periodduration));
            appendvestingentry(account, periodconclusiontime, periodquantity);
        }

        
        uint finalperiodquantity = safesub(totalquantity, safemul(periodquantity, (vestingperiods  1)));
        appendvestingentry(account, conclusiontime, finalperiodquantity);
    }

}
