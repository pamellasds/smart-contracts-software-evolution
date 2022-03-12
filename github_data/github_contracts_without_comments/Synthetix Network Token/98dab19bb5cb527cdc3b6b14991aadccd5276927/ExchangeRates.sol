pragma solidity ^0.5.16;


import ;
import ;
import ;


import ;



import ;



contract exchangerates is owned, selfdestructible, iexchangerates {
    using safemath for uint;
    using safedecimalmath for uint;

    struct rateandupdatedtime {
        uint216 rate;
        uint40 time;
    }

    
    mapping(bytes32 => mapping(uint => rateandupdatedtime)) private _rates;

    
    address public oracle;

    
    mapping(bytes32 => aggregatorinterface) public aggregators;

    
    bytes32[] public aggregatorkeys;

    
    uint private constant oracle_future_limit = 10 minutes;

    
    uint public ratestaleperiod = 3 hours;

    
    struct inversepricing {
        uint entrypoint;
        uint upperlimit;
        uint lowerlimit;
        bool frozen;
    }
    mapping(bytes32 => inversepricing) public inversepricing;
    bytes32[] public invertedkeys;

    mapping(bytes32 => uint) public currentroundforrate;

    

    constructor(
        address _owner,
        address _oracle,
        bytes32[] memory _currencykeys,
        uint[] memory _newrates
    ) public owned(_owner) selfdestructible() {
        require(_currencykeys.length == _newrates.length, );

        oracle = _oracle;

        
        _setrate(, safedecimalmath.unit(), now);

        internalupdaterates(_currencykeys, _newrates, now);
    }

    

    function setoracle(address _oracle) external onlyowner {
        oracle = _oracle;
        emit oracleupdated(oracle);
    }

    function setratestaleperiod(uint _time) external onlyowner {
        ratestaleperiod = _time;
        emit ratestaleperiodupdated(ratestaleperiod);
    }

    

    
    function updaterates(
        bytes32[] calldata currencykeys,
        uint[] calldata newrates,
        uint timesent
    ) external onlyoracle returns (bool) {
        return internalupdaterates(currencykeys, newrates, timesent);
    }

    
    function deleterate(bytes32 currencykey) external onlyoracle {
        require(getrate(currencykey) > 0, );

        delete _rates[currencykey][currentroundforrate[currencykey]];

        currentroundforrate[currencykey];

        emit ratedeleted(currencykey);
    }

    
    function setinversepricing(
        bytes32 currencykey,
        uint entrypoint,
        uint upperlimit,
        uint lowerlimit,
        bool freeze,
        bool freezeatupperlimit
    ) external onlyowner {
        
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

    
    function removeinversepricing(bytes32 currencykey) external onlyowner {
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
        if (address(aggregators[currencykey]) == address(0)) {
            aggregatorkeys.push(currencykey);
        }
        aggregators[currencykey] = aggregator;
        emit aggregatoradded(currencykey, address(aggregator));
    }

    
    function removeaggregator(bytes32 currencykey) external onlyowner {
        address aggregator = address(aggregators[currencykey]);
        require(aggregator != address(0), );
        delete aggregators[currencykey];

        bool wasremoved = removefromarray(currencykey, aggregatorkeys);

        if (wasremoved) {
            emit aggregatorremoved(currencykey, aggregator);
        }
    }

    function getlastroundidbeforeelapsedsecs(
        bytes32 currencykey,
        uint startingroundid,
        uint startingtimestamp,
        uint timediff
    ) external view returns (uint) {
        uint roundid = startingroundid;
        uint nexttimestamp = 0;
        while (true) {
            (, nexttimestamp) = getrateandtimestampatround(currencykey, roundid + 1);
            
            if (nexttimestamp == 0 || nexttimestamp > startingtimestamp + timediff) {
                return roundid;
            }
            roundid++;
        }
        return roundid;
    }

    function getcurrentroundid(bytes32 currencykey) external view returns (uint) {
        if (address(aggregators[currencykey]) != address(0)) {
            aggregatorinterface aggregator = aggregators[currencykey];
            return aggregator.latestround();
        } else {
            return currentroundforrate[currencykey];
        }
    }

    function effectivevalueatround(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        uint roundidforsrc,
        uint roundidfordest
    ) external view returns (uint) {
        
        if (sourcecurrencykey == destinationcurrencykey) return sourceamount;

        (uint srcrate, ) = getrateandtimestampatround(sourcecurrencykey, roundidforsrc);
        (uint destrate, ) = getrateandtimestampatround(destinationcurrencykey, roundidfordest);
        
        return sourceamount.multiplydecimalround(srcrate).dividedecimalround(destrate);
    }

    function rateandtimestampatround(bytes32 currencykey, uint roundid) external view returns (uint rate, uint time) {
        return getrateandtimestampatround(currencykey, roundid);
    }

    

    
    function lastrateupdatetimes(bytes32 currencykey) public view returns (uint256) {
        return getrateandupdatedtime(currencykey).time;
    }

    
    function lastrateupdatetimesforcurrencies(bytes32[] memory currencykeys) public view returns (uint[] memory) {
        uint[] memory lastupdatetimes = new uint[](currencykeys.length);

        for (uint i = 0; i < currencykeys.length; i++) {
            lastupdatetimes[i] = lastrateupdatetimes(currencykeys[i]);
        }

        return lastupdatetimes;
    }

    
    function effectivevalue(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) public view returns (uint) {
        
        if (sourcecurrencykey == destinationcurrencykey) return sourceamount;

        
        return
            sourceamount.multiplydecimalround(getrate(sourcecurrencykey)).dividedecimalround(
                getrate(destinationcurrencykey)
            );
    }

    
    function rateforcurrency(bytes32 currencykey) external view returns (uint) {
        return getrateandupdatedtime(currencykey).rate;
    }

    
    function ratesforcurrencies(bytes32[] calldata currencykeys) external view returns (uint[] memory) {
        uint[] memory _localrates = new uint[](currencykeys.length);

        for (uint i = 0; i < currencykeys.length; i++) {
            _localrates[i] = getrate(currencykeys[i]);
        }

        return _localrates;
    }

    
    function ratesandstaleforcurrencies(bytes32[] calldata currencykeys) external view returns (uint[] memory, bool) {
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

    
    function rateisstale(bytes32 currencykey) public view returns (bool) {
        
        if (currencykey == ) return false;

        return lastrateupdatetimes(currencykey).add(ratestaleperiod) < now;
    }

    
    function rateisfrozen(bytes32 currencykey) external view returns (bool) {
        return inversepricing[currencykey].frozen;
    }

    
    function anyrateisstale(bytes32[] calldata currencykeys) external view returns (bool) {
        
        uint256 i = 0;

        while (i < currencykeys.length) {
            
            if (currencykeys[i] !=  && lastrateupdatetimes(currencykeys[i]).add(ratestaleperiod) < now) {
                return true;
            }
            i += 1;
        }

        return false;
    }

    

    function _setrate(
        bytes32 currencykey,
        uint256 rate,
        uint256 time
    ) internal {
        
        currentroundforrate[currencykey]++;

        _rates[currencykey][currentroundforrate[currencykey]] = rateandupdatedtime({
            rate: uint216(rate),
            time: uint40(time)
        });
    }

    
    function internalupdaterates(
        bytes32[] memory currencykeys,
        uint[] memory newrates,
        uint timesent
    ) internal returns (bool) {
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

        
        uint newinverserate = getrate(currencykey);

        
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

    function getrateandupdatedtime(bytes32 currencykey) internal view returns (rateandupdatedtime memory) {
        if (address(aggregators[currencykey]) != address(0)) {
            return
                rateandupdatedtime({
                    rate: uint216(aggregators[currencykey].latestanswer() * 1e10),
                    time: uint40(aggregators[currencykey].latesttimestamp())
                });
        } else {
            return _rates[currencykey][currentroundforrate[currencykey]];
        }
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

    function getrateandtimestampatround(bytes32 currencykey, uint roundid) internal view returns (uint rate, uint time) {
        if (address(aggregators[currencykey]) != address(0)) {
            aggregatorinterface aggregator = aggregators[currencykey];
            return (uint(aggregator.getanswer(roundid) * 1e10), aggregator.gettimestamp(roundid));
        } else {
            rateandupdatedtime storage update = _rates[currencykey][roundid];
            return (update.rate, update.time);
        }
    }

    function getrate(bytes32 currencykey) internal view returns (uint256) {
        return getrateandupdatedtime(currencykey).rate;
    }

    

    modifier onlyoracle {
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
