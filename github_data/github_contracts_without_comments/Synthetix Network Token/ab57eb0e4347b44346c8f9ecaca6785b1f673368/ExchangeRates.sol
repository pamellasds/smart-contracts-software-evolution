pragma solidity 0.4.25;

import ;
import ;
import ;


import ;



contract exchangerates is selfdestructible {


    using safemath for uint;
    using safedecimalmath for uint;

    struct rateandupdatedtime {
        uint216 rate;
        uint40 time;
    }

    
    mapping(bytes32 => rateandupdatedtime) private _rates;

    
    address public oracle;

    
    mapping(bytes32 => aggregatorinterface) public aggregators;

    
    bytes32[] public aggregatorkeys;

    
    uint constant oracle_future_limit = 10 minutes;

    
    uint public ratestaleperiod = 3 hours;

    
    struct inversepricing {
        uint entrypoint;
        uint upperlimit;
        uint lowerlimit;
        bool frozen;
    }
    mapping(bytes32 => inversepricing) public inversepricing;
    bytes32[] public invertedkeys;

    

    
    constructor(
        
        address _owner,

        
        address _oracle,
        bytes32[] _currencykeys,
        uint[] _newrates
    )
        
        selfdestructible(_owner)
        public
    {
        require(_currencykeys.length == _newrates.length, );

        oracle = _oracle;

        
        _setrate(, safedecimalmath.unit(), now);

        internalupdaterates(_currencykeys, _newrates, now);
    }

    function getrateandupdatedtime(bytes32 code) internal view returns (rateandupdatedtime) {
        if (aggregators[code] != address(0)) {
            return rateandupdatedtime({
                rate: uint216(aggregators[code].latestanswer() * 1e10),
                time: uint40(aggregators[code].latesttimestamp())
            });
        } else {
            return _rates[code];
        }
    }
    
    function rates(bytes32 code) public view returns(uint256) {
        return getrateandupdatedtime(code).rate;
    }

    
    function lastrateupdatetimes(bytes32 code) public view returns(uint256) {
        return getrateandupdatedtime(code).time;
    }

    
    function lastrateupdatetimesforcurrencies(bytes32[] currencykeys)
        public
        view
        returns (uint[])
    {
        uint[] memory lastupdatetimes = new uint[](currencykeys.length);

        for (uint i = 0; i < currencykeys.length; i++) {
            lastupdatetimes[i] = lastrateupdatetimes(currencykeys[i]);
        }

        return lastupdatetimes;
    }

    function _setrate(bytes32 code, uint256 rate, uint256 time) internal {
        _rates[code] = rateandupdatedtime({
            rate: uint216(rate),
            time: uint40(time)
        });
    }

    

    
    function updaterates(bytes32[] currencykeys, uint[] newrates, uint timesent)
        external
        onlyoracle
        returns(bool)
    {
        return internalupdaterates(currencykeys, newrates, timesent);
    }

    
    function internalupdaterates(bytes32[] currencykeys, uint[] newrates, uint timesent)
        internal
        returns(bool)
    {
        require(currencykeys.length == newrates.length, );
        require(timesent < (now + oracle_future_limit), );

        
        for (uint i = 0; i < currencykeys.length; i++) {
            bytes32 currencykey = currencykeys[i];

            
            
            
            require(newrates[i] != 0, );
            require(currencykey != , );

            
            if (timesent < lastrateupdatetimes(currencykey)) {
                continue;
            }

            newrates[i] = rateorinverted(currencykey, newrates[i]);

            
            _setrate(currencykey, newrates[i], timesent);
        }

        emit ratesupdated(currencykeys, newrates);

        return true;
    }

    
    function rateorinverted(bytes32 currencykey, uint rate) internal returns (uint) {
        
        inversepricing storage inverse = inversepricing[currencykey];
        if (inverse.entrypoint <= 0) {
            return rate;
        }

        
        uint newinverserate = rates(currencykey);

        
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

    
    function deleterate(bytes32 currencykey)
        external
        onlyoracle
    {
        require(rates(currencykey) > 0, );

        delete _rates[currencykey];

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

    
    function setinversepricing(bytes32 currencykey, uint entrypoint, uint upperlimit, uint lowerlimit, bool freeze, bool freezeatupperlimit)
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
        inversepricing[currencykey].frozen = freeze;

        emit inversepriceconfigured(currencykey, entrypoint, upperlimit, lowerlimit);

        
        
        
        if (freeze) {
            emit inversepricefrozen(currencykey);

            _setrate(currencykey, freezeatupperlimit ? upperlimit : lowerlimit, now);
        }
    }

    
    function removeinversepricing(bytes32 currencykey) external onlyowner
    {
        require(inversepricing[currencykey].entrypoint > 0, );

        inversepricing[currencykey].entrypoint = 0;
        inversepricing[currencykey].upperlimit = 0;
        inversepricing[currencykey].lowerlimit = 0;
        inversepricing[currencykey].frozen = false;

        
        bool wasremoved = removefromarray(currencykey, invertedkeys);

        if (wasremoved) {
            emit inversepriceconfigured(currencykey, 0, 0, 0);
        }
    }

    
    function addaggregator(bytes32 currencykey, address aggregatoraddress) external onlyowner {
        aggregatorinterface aggregator = aggregatorinterface(aggregatoraddress);
        require(aggregator.latesttimestamp() >= 0, );
        if (aggregators[currencykey] == address(0)) {
            aggregatorkeys.push(currencykey);
        }
        aggregators[currencykey] = aggregator;
        emit aggregatoradded(currencykey, aggregator);
    }

    
    function removefromarray(bytes32 entry, bytes32[] storage array) internal returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == entry) {
                delete array[i];

                
                
                
                array[i] = array[array.length  1];

                
                array.length;

                return true;
            }
        }
        return false;
    }
    
    function removeaggregator(bytes32 currencykey) external onlyowner {
        address aggregator = aggregators[currencykey];
        require(aggregator != address(0), );
        delete aggregators[currencykey];

        bool wasremoved = removefromarray(currencykey, aggregatorkeys);

        if (wasremoved) {
            emit aggregatorremoved(currencykey, aggregator);
        }
    }

    

    
    function effectivevalue(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
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

    
    function rateforcurrency(bytes32 currencykey)
        public
        view
        returns (uint)
    {
        return rates(currencykey);
    }

    
    function ratesforcurrencies(bytes32[] currencykeys)
        public
        view
        returns (uint[])
    {
        uint[] memory _localrates = new uint[](currencykeys.length);

        for (uint i = 0; i < currencykeys.length; i++) {
            _localrates[i] = rates(currencykeys[i]);
        }

        return _localrates;
    }

    
    function ratesandstaleforcurrencies(bytes32[] currencykeys)
        public
        view
        returns (uint[], bool)
    {
        uint[] memory _localrates = new uint[](currencykeys.length);

        bool anyratestale = false;
        uint period = ratestaleperiod;
        for (uint i = 0; i < currencykeys.length; i++) {
            rateandupdatedtime memory rateandupdatetime = getrateandupdatedtime(currencykeys[i]);
            _localrates[i] = uint256(rateandupdatetime.rate);
            if (!anyratestale) {
                anyratestale = (currencykeys[i] !=  && uint256(rateandupdatetime.time).add(period) < now);
            }
        }

        return (_localrates, anyratestale);
    }

    
    function rateisstale(bytes32 currencykey)
        public
        view
        returns (bool)
    {
        
        if (currencykey == ) return false;

        return lastrateupdatetimes(currencykey).add(ratestaleperiod) < now;
    }

    
    function rateisfrozen(bytes32 currencykey)
        external
        view
        returns (bool)
    {
        return inversepricing[currencykey].frozen;
    }


    
    function anyrateisstale(bytes32[] currencykeys)
        external
        view
        returns (bool)
    {
        
        uint256 i = 0;

        while (i < currencykeys.length) {
            
            if (currencykeys[i] !=  && lastrateupdatetimes(currencykeys[i]).add(ratestaleperiod) < now) {
                return true;
            }
            i += 1;
        }

        return false;
    }

    

    modifier ratenotstale(bytes32 currencykey) {
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
    event ratesupdated(bytes32[] currencykeys, uint[] newrates);
    event ratedeleted(bytes32 currencykey);
    event inversepriceconfigured(bytes32 currencykey, uint entrypoint, uint upperlimit, uint lowerlimit);
    event inversepricefrozen(bytes32 currencykey);
    event aggregatoradded(bytes32 currencykey, address aggregator);
    event aggregatorremoved(bytes32 currencykey, address aggregator);
}
