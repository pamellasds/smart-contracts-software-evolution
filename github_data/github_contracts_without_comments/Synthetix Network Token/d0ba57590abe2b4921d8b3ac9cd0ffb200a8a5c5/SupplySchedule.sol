

pragma solidity 0.4.25;

import ;
import ;
import ;


contract supplyschedule is owned {
    using safemath for uint;
    using safedecimalmath for uint;

    
    struct scheduledata {
        
        uint totalsupply;

        
        uint startperiod;

        
        uint endperiod;

        
        uint totalsupplyminted;
    }

    
    uint public mintperiodduration = 1 weeks;

    
    uint public lastmintevent;

    synthetix public synthetix;

    uint constant seconds_in_year = 60 * 60 * 24 * 365;

    
    uint public constant start_date = 1520294400; 
    uint public constant year_one = start_date + seconds_in_year.mul(1);
    uint public constant year_two = start_date + seconds_in_year.mul(2);
    uint public constant year_three = start_date + seconds_in_year.mul(3);
    uint public constant year_four = start_date + seconds_in_year.mul(4);
    uint public constant year_five = start_date + seconds_in_year.mul(5);
    uint public constant year_six = start_date + seconds_in_year.mul(6);
    uint public constant year_seven = start_date + seconds_in_year.mul(7);

    uint8 constant public inflation_schedules_length = 7;
    scheduledata[inflation_schedules_length] public schedules;

    constructor(address _owner)
        owned(_owner)
        public
    {
        
        
        schedules[0] = scheduledata(1e8 * safedecimalmath.unit(), start_date, year_one  1, 1e8 * safedecimalmath.unit());
        schedules[1] = scheduledata(75e6 * safedecimalmath.unit(), year_one, year_two  1, 0); 
        schedules[2] = scheduledata(37.5e6 * safedecimalmath.unit(), year_two, year_three  1, 0); 
        schedules[3] = scheduledata(18.75e6 * safedecimalmath.unit(), year_three, year_four  1, 0); 
        schedules[4] = scheduledata(9.375e6 * safedecimalmath.unit(), year_four, year_five  1, 0); 
        schedules[5] = scheduledata(4.6875e6 * safedecimalmath.unit(), year_five, year_six  1, 0); 
        schedules[6] = scheduledata(0, year_six, year_seven  1, 0); 
    }

    
    function setsynthetix(synthetix _synthetix)
        external
        onlyowner
    {
        synthetix = _synthetix;
        
    }

    
    function mintablesupply()
        public
        view
        returns (uint)
    {
        if (!ismintable()) {
            return 0;
        }

        uint index = getcurrentschedule();

        
        uint amountpreviousperiod = _remainingsupplyfrompreviousyear(index);

        

        
        
        
        scheduledata memory schedule = schedules[index];

        uint weeksinperiod = (schedule.endperiod  schedule.startperiod).div(mintperiodduration);

        uint supplyperweek = schedule.totalsupply.dividedecimal(weeksinperiod);

        uint weekstomint = lastmintevent >= schedule.startperiod ? _numweeksroundeddown(now.sub(lastmintevent)) : _numweeksroundeddown(now.sub(schedule.startperiod));
        

        uint amountinperiod = supplyperweek.multiplydecimal(weekstomint);
        return amountinperiod.add(amountpreviousperiod);
    }

    function _numweeksroundeddown(uint _timediff)
        public
        view
        returns (uint)
    {
        
        
        
        return _timediff.div(mintperiodduration);
    }

    function ismintable()
        public
        view
        returns (bool)
    {
        bool mintable = false;
        if (now  lastmintevent > mintperiodduration && now <= schedules[6].endperiod) 
        {
            mintable = true;
        }
        return mintable;
    }

    
    
    function getcurrentschedule()
        public
        view
        returns (uint)
    {
        require(now <= schedules[6].endperiod, );

        for (uint i = 0; i < inflation_schedules_length; i++) {
            if (schedules[i].startperiod <= now && schedules[i].endperiod >= now) {
                return i;
            }
        }
    }

    function _remainingsupplyfrompreviousyear(uint currentschedule)
        internal
        view
        returns (uint)
    {
        
        
        if (currentschedule == 0 || lastmintevent > schedules[currentschedule  1].endperiod) {
            return 0;
        }

        
        uint amountinperiod = schedules[currentschedule  1].totalsupply.sub(schedules[currentschedule  1].totalsupplyminted);

        
        if (amountinperiod < 0) {
            return 0;
        }

        return amountinperiod;
    }

    
    function updatemintvalues()
        external
        onlysynthetix
        returns (bool)
    {
        
        uint currentindex = getcurrentschedule();
        uint lastperiodamount = _remainingsupplyfrompreviousyear(currentindex);
        uint currentperiodamount = mintablesupply().sub(lastperiodamount);

        
        if (lastperiodamount > 0) {
            schedules[currentindex  1].totalsupplyminted = schedules[currentindex  1].totalsupplyminted.add(lastperiodamount);
        }

        
        schedules[currentindex].totalsupplyminted = schedules[currentindex].totalsupplyminted.add(currentperiodamount);
        
        lastmintevent = now;

        emit supplyminted(lastperiodamount, currentperiodamount, currentindex, now);
        return true;
    }

    

    modifier onlysynthetix() {
        require(msg.sender == address(synthetix), );
        _;
    }

    

    event supplyminted(uint previousperiodamount, uint currentamount, uint indexed schedule, uint timestamp);
}
