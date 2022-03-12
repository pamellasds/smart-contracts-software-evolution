

pragma solidity 0.4.24;

import ;
import ;
import ;
import ;
import ;


contract issuancecontroller is safedecimalmath, selfdestructible, pausable {

    
    havven public havven;
    nomin public nomin;

    
    address public fundswallet;

    
    address public oracle;
    
    uint constant oracle_future_limit = 10 minutes;

    
    uint public pricestaleperiod = 3 hours;

    
    uint public lastpriceupdatetime;
    
    uint public usdtohavprice;
    
    uint public usdtoethprice;
    
    

    
    constructor(
        
        address _owner,

        
        address _fundswallet,

        
        havven _havven,
        nomin _nomin,

        
        address _oracle,
        uint _usdtoethprice,
        uint _usdtohavprice
    )
        
        selfdestructible(_owner)
        pausable(_owner)
        public
    {
        fundswallet = _fundswallet;
        havven = _havven;
        nomin = _nomin;
        oracle = _oracle;
        usdtoethprice = _usdtoethprice;
        usdtohavprice = _usdtohavprice;
        lastpriceupdatetime = now;
    }

    

    
    function setfundswallet(address _fundswallet)
        external
        onlyowner
    {
        fundswallet = _fundswallet;
        emit fundswalletupdated(fundswallet);
    }
    
    
    function setoracle(address _oracle)
        external
        onlyowner
    {
        oracle = _oracle;
        emit oracleupdated(oracle);
    }

    
    function setnomin(nomin _nomin)
        external
        onlyowner
    {
        nomin = _nomin;
        emit nominupdated(_nomin);
    }

    
    function sethavven(havven _havven)
        external
        onlyowner
    {
        havven = _havven;
        emit havvenupdated(_havven);
    }

    
    function setpricestaleperiod(uint _time)
        external
        onlyowner 
    {
        pricestaleperiod = _time;
        emit pricestaleperiodupdated(pricestaleperiod);
    }

    
    
    function updateprices(uint newethprice, uint newhavvenprice, uint timesent)
        external
        onlyoracle
    {
        
        require(lastpriceupdatetime < timesent && timesent < now + oracle_future_limit);

        usdtoethprice = newethprice;
        usdtohavprice = newhavvenprice;
        lastpriceupdatetime = timesent;

        emit pricesupdated(usdtoethprice, usdtohavprice, lastpriceupdatetime);
    }

    
    function ()
        external
        payable
    {
        exchangeetherfornomins();
    } 

    
    
    function exchangeetherfornomins()
        public 
        payable
        pricesnotstale
        notpaused
        returns (uint) 
    {
        
        
        uint requestedtopurchase = safemul_dec(msg.value, usdtoethprice);

        
        fundswallet.transfer(msg.value);

        
        
        
        
        nomin.transfer(msg.sender, requestedtopurchase);

        
        
        
        

        return requestedtopurchase;
    }

    
    function exchangenominsforhavvens(uint amount)
        external
        pricesnotstale
        notpaused
        returns (uint) 
    {
        
        uint havvenstosend = havvensreceivedfornomins(amount);
        
        
        nomin.transferfrom(msg.sender, this, amount);

        
        havven.transfer(msg.sender, havvenstosend);

        
        
        
        

        return havvenstosend; 
    }

    
    function withdrawhavvens(uint amount)
        external
        onlyowner
    {
        havven.transfer(owner, amount);
        
        
        
        
        
    }

    
    function withdrawnomins(uint amount)
        external
        onlyowner
    {
        nomin.transfer(owner, amount);
        
        
        
        
        
    }

    
    
    function pricesarestale()
        public
        view
        returns (bool)
    {
        return safeadd(lastpriceupdatetime, pricestaleperiod) < now;
    }

    
    function havvensreceivedfornomins(uint amount)
        public 
        view
        returns (uint)
    {
        uint nominsreceived = nomin.amountreceived(amount);
        return safediv_dec(nominsreceived, usdtohavprice);
    }

    
    function nominsreceivedforether(uint amount)
        public 
        view
        returns (uint)
    {
        uint nominstransferred = safemul_dec(amount, usdtoethprice);
        return nomin.amountreceived(nominstransferred);
    }
    
    

    modifier onlyoracle
    {
        require(msg.sender == oracle);
        _;
    }

    modifier pricesnotstale
    {
        require(!pricesarestale());
        _;
    }

    

    event fundswalletupdated(address newfundswallet);
    event oracleupdated(address neworacle);
    event nominupdated(nomin newnomincontract);
    event havvenupdated(havven newhavvencontract);
    event pricestaleperiodupdated(uint pricestaleperiod);
    event pricesupdated(uint newethprice, uint newhavvenprice, uint timesent);
}
