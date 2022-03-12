

pragma solidity 0.4.25;

import ;
import ;
import ;



contract exchangerates is selfdestructible {


    using safemath for uint;
    using safedecimalmath for uint;

    
    mapping(bytes4 => uint) public rates;

    
    mapping(bytes4 => uint) public lastrateupdatetimes;

    
    address public oracle;

    
    uint constant oracle_future_limit = 10 minutes;

    
    uint public ratestaleperiod = 3 hours;

    
    
    
    bytes4[5] public xdrparticipants;

    
    struct inversepricing {
        uint entrypoint;
        uint upperlimit;
        uint lowerlimit;
        bool frozen;
    }
    mapping(bytes4 => inversepricing) public inversepricing;
    bytes4[] public invertedkeys;

    

    
    constructor(
        
        address _owner,

        
        address _oracle,
        bytes4[] _currencykeys,
        uint[] _newrates
    )
        
        selfdestructible(_owner)
        public
    {
        require(_currencykeys.length == _newrates.length, );

        oracle = _oracle;

        
        rates[] = safedecimalmath.unit();
        lastrateupdatetimes[] = now;

        
        
        
        
        
        
        
        xdrparticipants = [
            bytes4(),
            bytes4(),
            bytes4(),
            bytes4(),
            bytes4()
        ];

        internalupdaterates(_currencykeys, _newrates, now);
    }

    

    
    function updaterates(bytes4[] currencykeys, uint[] newrates, uint timesent)
        external
        onlyoracle
        returns(bool)
    {
        return internalupdaterates(currencykeys, newrates, timesent);
    }

    
    function internalupdaterates(bytes4[] currencykeys, uint[] newrates, uint timesent)
        internal
        returns(bool)
    {
        require(currencykeys.length == newrates.length, );
        require(timesent < (now + oracle_future_limit), );

        
        for (uint i = 0; i < currencykeys.length; i++) {
            
            
            
            require(newrates[i] != 0, );
            require(currencykeys[i] != , );

            
            if (timesent < lastrateupdatetimes[currencykeys[i]]) {
                continue;
            }

            newrates[i] = rateorinverted(currencykeys[i], newrates[i]);

            
            rates[currencykeys[i]] = newrates[i];
            lastrateupdatetimes[currencykeys[i]] = timesent;
        }

        emit ratesupdated(currencykeys, newrates);

        
        updatexdrrate(timesent);

        return true;
    }

    
    function rateorinverted(bytes4 currencykey, uint rate) internal returns (uint) {
        
        inversepricing storage inverse = inversepricing[currencykey];
        if (inverse.entrypoint <= 0) {
            return rate;
        }

        
        uint newinverserate = rates[currencykey];

        
        if (!inverse.frozen) {
            uint doubleentrypoint = inverse.entrypoint.mul(2);
            if (doubleentrypoint <= rate) {
                
                
                
                newinverserate = 0;
            } else {
                newinverserate = doubleentrypoint.sub(rate);
            }

            
            if (newinverserate >= inverse.upperlimit) {
                newinverserate = inverse.upperlimit;
            } else if (newinverserate <= inverse.lowerlimit) {
                newinverserate = inverse.lowerlimit;
            }

            if (newinverserate == inverse.upperlimit || newinverserate == inverse.lowerlimit) {
                inverse.frozen = true;
                emit inversepricefrozen(currencykey);
            }
        }

        return newinverserate;
    }

    
    function updatexdrrate(uint timesent)
        internal
    {
        uint total = 0;

        for (uint i = 0; i < xdrparticipants.length; i++) {
            total = rates[xdrparticipants[i]].add(total);
        }

        
        rates[] = total;

        
        lastrateupdatetimes[] = timesent;

        
        
        bytes4[] memory eventcurrencycode = new bytes4[](1);
        eventcurrencycode[0] = ;

        uint[] memory eventrate = new uint[](1);
        eventrate[0] = rates[];

        emit ratesupdated(eventcurrencycode, eventrate);
    }

    
    function deleterate(bytes4 currencykey)
        external
        onlyoracle
    {
        require(rates[currencykey] > 0, );

        delete rates[currencykey];
        delete lastrateupdatetimes[currencykey];

        emit ratedeleted(currencykey);
    }

    
    function setoracle(address _oracle)
        external
        onlyowner
    {
        oracle = _oracle;
        emit oracleupdated(oracle);
    }

    
    function setratestaleperiod(uint _time)
        external
        onlyowner
    {
        ratestaleperiod = _time;
        emit ratestaleperiodupdated(ratestaleperiod);
    }

    
    function setinversepricing(bytes4 currencykey, uint entrypoint, uint upperlimit, uint lowerlimit)
        external onlyowner
    {
        require(entrypoint > 0, );
        require(lowerlimit > 0, );
        require(upperlimit > entrypoint, );
        require(upperlimit < entrypoint.mul(2), );
        require(lowerlimit < entrypoint, );

        if (inversepricing[currencykey].entrypoint <= 0) {
            
            invertedkeys.push(currencykey);
        }
        inversepricing[currencykey].entrypoint = entrypoint;
        inversepricing[currencykey].upperlimit = upperlimit;
        inversepricing[currencykey].lowerlimit = lowerlimit;
        inversepricing[currencykey].frozen = false;

        emit inversepriceconfigured(currencykey, entrypoint, upperlimit, lowerlimit);
    }

    
    function removeinversepricing(bytes4 currencykey) external onlyowner {
        inversepricing[currencykey].entrypoint = 0;
        inversepricing[currencykey].upperlimit = 0;
        inversepricing[currencykey].lowerlimit = 0;
        inversepricing[currencykey].frozen = false;

        
        for (uint8 i = 0; i < invertedkeys.length; i++) {
            if (invertedkeys[i] == currencykey) {
                delete invertedkeys[i];

                
                
                
                invertedkeys[i] = invertedkeys[invertedkeys.length  1];

                
                invertedkeys.length;

                break;
            }
        }

        emit inversepriceconfigured(currencykey, 0, 0, 0);
    }
    

    
    function effectivevalue(bytes4 sourcecurrencykey, uint sourceamount, bytes4 destinationcurrencykey)
        public
        view
        ratenotstale(sourcecurrencykey)
        ratenotstale(destinationcurrencykey)
        returns (uint)
    {
        
        if (sourcecurrencykey == destinationcurrencykey) return sourceamount;

        
        return sourceamount.multiplydecimalround(rateforcurrency(sourcecurrencykey))
            .dividedecimalround(rateforcurrency(destinationcurrencykey));
    }

    
    function rateforcurrency(bytes4 currencykey)
        public
        view
        returns (uint)
    {
        return rates[currencykey];
    }

    
    function ratesforcurrencies(bytes4[] currencykeys)
        public
        view
        returns (uint[])
    {
        uint[] memory _rates = new uint[](currencykeys.length);

        for (uint8 i = 0; i < currencykeys.length; i++) {
            _rates[i] = rates[currencykeys[i]];
        }

        return _rates;
    }

    
    function lastrateupdatetimeforcurrency(bytes4 currencykey)
        public
        view
        returns (uint)
    {
        return lastrateupdatetimes[currencykey];
    }

    
    function lastrateupdatetimesforcurrencies(bytes4[] currencykeys)
        public
        view
        returns (uint[])
    {
        uint[] memory lastupdatetimes = new uint[](currencykeys.length);

        for (uint8 i = 0; i < currencykeys.length; i++) {
            lastupdatetimes[i] = lastrateupdatetimes[currencykeys[i]];
        }

        return lastupdatetimes;
    }

    
    function rateisstale(bytes4 currencykey)
        public
        view
        returns (bool)
    {
        
        if (currencykey == ) return false;

        return lastrateupdatetimes[currencykey].add(ratestaleperiod) < now;
    }

    
    function rateisfrozen(bytes4 currencykey)
        external
        view
        returns (bool)
    {
        return inversepricing[currencykey].frozen;
    }


    
    function anyrateisstale(bytes4[] currencykeys)
        external
        view
        returns (bool)
    {
        
        uint256 i = 0;

        while (i < currencykeys.length) {
            
            if (currencykeys[i] !=  && lastrateupdatetimes[currencykeys[i]].add(ratestaleperiod) < now) {
                return true;
            }
            i += 1;
        }

        return false;
    }

    

    modifier ratenotstale(bytes4 currencykey) {
        require(!rateisstale(currencykey), );
        _;
    }

    modifier onlyoracle
    {
        require(msg.sender == oracle, );
        _;
    }

    

    event oracleupdated(address neworacle);
    event ratestaleperiodupdated(uint ratestaleperiod);
    event ratesupdated(bytes4[] currencykeys, uint[] newrates);
    event ratedeleted(bytes4 currencykey);
    event inversepriceconfigured(bytes4 currencykey, uint entrypoint, uint upperlimit, uint lowerlimit);
    event inversepricefrozen(bytes4 currencykey);
}
