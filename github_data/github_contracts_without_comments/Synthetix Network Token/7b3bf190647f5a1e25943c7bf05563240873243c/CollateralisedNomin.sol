

pragma solidity ^0.4.19;

import ;


contract collateralisednomin is erc20feetoken {
    
    
    address oracle;

    
    address beneficiary;
    
    
    string public constant name = ;
    string public constant symbol = ;

    
    uint public pool = 0;
    
    
    uint public poolfee = unit / 200;
    
    
    uint public purchasemininum = unit / 100;

    
    uint public collatratiominimum =  2 * unit;

    
    uint public liquidationperiod = 90 days;
    
    
    uint public maxliquidationperiod = 180 days;

    
    
    
    uint public liquidationtimestamp = ~uint(0);
    
    
    uint public etherprice;
    
    
    uint public lastpriceupdate;

    
    
    uint public staleperiod = 3 days;

    
    function collateralisednomin(address _owner, address _oracle,
                                 address _beneficiary, uint initialetherprice)
        erc20feetoken(_owner)
        public
    {
        oracle = _oracle;
        beneficiary = _beneficiary;
        etherprice = initialetherprice;
        lastpriceupdate = now;

        
        transferfee = unit / 1000; 
    }

    
    modifier onlyoracle
    {
        require(msg.sender == oracle);
        _;
    }

    
    modifier notliquidating
    {
        require(!isliquidating());
        _;
    }

    modifier pricenotstale
    {
        require(!priceisstale());
        _;
    }  
    
    
    function setoracle(address neworacle)
        public
        onlyowner
    {
        oracle = neworacle;
    }
    
    
    function setbeneficiary(address newbeneficiary)
        public
        onlyowner
    {
        beneficiary = newbeneficiary;
    }
    
    
    function fiatvalue(uint eth)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safemul(eth, etherprice);
    }
    
    
    function fiatbalance()
        public
        view
        returns (uint)
    {
        
        return fiatvalue(this.balance);
    }
    
    
    function ethervalue(uint fiat)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safediv(fiat, etherprice);
    }

    
    function transferfeeincurred(uint n)
        public
        view
        returns (uint)
    {
        return safemul(n, transferfee);
    }

    
    function issue(uint n)
        public
        onlyowner
        payable
    {
        
        
        
        require(fiatvalue(msg.value) + fiatbalance() >= safemul(supply + n, collatratiominimum));
        supply = safeadd(supply, n);
        pool = safeadd(pool, n);
        issuance(n, msg.value);
    }

    
    function burn(uint n)
        public
        onlyowner
    {
        
        require(pool >= n);
        pool = safesub(pool, n);
        supply = safesub(supply, n);
        burning(n);
    }

    
    function poolfeeincurred(uint n)
        public
        view
        returns (uint)
    {
        return safemul(n, poolfee);
    }

    
    function purchasecostfiat(uint n)
        public
        view
        returns (uint)
    {
        return safeadd(n, poolfeeincurred(n));
    }

    
    function purchasecostether(uint n)
        public
        view
        returns (uint)
    {
        
        return ethervalue(purchasecostfiat(n));
    }

    
    function buy(uint n)
        public
        notliquidating
        payable
    {
        
        require(n >= purchasemininum &&
                msg.value == purchasecostether(n));
        
        pool = safesub(pool, n);
        balances[msg.sender] = safeadd(balances[msg.sender], n);
        purchase(msg.sender, n, msg.value);
    }
    
    
    function saleproceedsfiat(uint n)
        public
        view
        returns (uint)
    {
        return safesub(n, poolfeeincurred(n));
    }

    
    function saleproceedsether(uint n)
        public
        view
        returns (uint)
    {
        
        return ethervalue(saleproceedsfiat(n));
    }

    
    function sell(uint n)
        public
    {
        uint proceeds = saleproceedsfiat(n);
        
        require(fiatbalance() >= proceeds);
        
        balances[msg.sender] = safesub(balances[msg.sender], n);
        pool = safeadd(pool, n);
        msg.sender.transfer(proceeds);
        sale(msg.sender, n, proceeds);
    }

    
    function setprice(uint price)
        public
        onlyoracle
    {
        etherprice = price;
        lastpriceupdate = now;
        priceupdate(price);
    }

    
    function setstaleperiod(uint period)
        public
        onlyowner
    {
        staleperiod = period;
        staleperiodupdate(period);
    }

    
    function priceisstale()
        public
        view
        returns (bool)
    {
        return lastpriceupdate + staleperiod < now;
    }

    
    function liquidate()
        public
        onlyowner
        notliquidating
    {
        liquidationtimestamp = now;
        liquidation();
    }

    
    function extendliquidationperiod(uint extension)
        public
        onlyowner
    {
        require(liquidationperiod + extension <= maxliquidationperiod);
        liquidationperiod += extension;
        liquidationextended(extension);
    }
    
    
    function isliquidating()
        public
        view
        returns (bool)
    {
        return liquidationtimestamp <= now;
    }
    
    
    function selfdestruct()
        public
        onlyowner
    {
        require(isliquidating() &&
                liquidationtimestamp + liquidationperiod < now);
        selfdestructed();
        selfdestruct(beneficiary);
    }

    
    event issuance(uint nominsissued, uint collateraldeposited);

    
    event burning(uint nominsburned);

    
    event purchase(address buyer, uint nomins, uint eth);

    
    event sale(address seller, uint nomins, uint eth);

    
    event priceupdate(uint newprice);

    
    event staleperiodupdate(uint newperiod);

    
    event liquidation();

    
    event liquidationextended(uint extension);

    
    event selfdestructed();
}
