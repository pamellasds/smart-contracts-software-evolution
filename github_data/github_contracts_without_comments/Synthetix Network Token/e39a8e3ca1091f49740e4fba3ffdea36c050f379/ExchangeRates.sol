pragma solidity ^0.5.16;


import ;
import ;
import ;
import ;
import ;


import ;



import ;

import ;
import ;



contract exchangerates is owned, selfdestructible, mixinresolver, mixinsystemsettings, iexchangerates {
    using safemath for uint;
    using safedecimalmath for uint;

    
    mapping(bytes32 => mapping(uint => rateandupdatedtime)) private _rates;

    
    address public oracle;

    
    mapping(bytes32 => aggregatorv2v3interface) public aggregators;

    mapping(bytes32 => uint8) public currencykeydecimals;

    
    bytes32[] public aggregatorkeys;

    
    uint private constant oracle_future_limit = 10 minutes;

    mapping(bytes32 => inversepricing) public inversepricing;

    bytes32[] public invertedkeys;

    mapping(bytes32 => uint) public currentroundforrate;

    
    bytes32 private constant contract_exchanger = ;

    bytes32[24] private addressestocache = [contract_exchanger];

    

    constructor(
        address _owner,
        address _oracle,
        address _resolver,
        bytes32[] memory _currencykeys,
        uint[] memory _newrates
    ) public owned(_owner) selfdestructible() mixinresolver(_resolver, addressestocache) mixinsystemsettings() {
        require(_currencykeys.length == _newrates.length, );

        oracle = _oracle;

        
        _setrate(, safedecimalmath.unit(), now);

        internalupdaterates(_currencykeys, _newrates, now);
    }

    

    function setoracle(address _oracle) external onlyowner {
        oracle = _oracle;
        emit oracleupdated(oracle);
    }

    

    function updaterates(
        bytes32[] calldata currencykeys,
        uint[] calldata newrates,
        uint timesent
    ) external onlyoracle returns (bool) {
        return internalupdaterates(currencykeys, newrates, timesent);
    }

    function deleterate(bytes32 currencykey) external onlyoracle {
        require(_getrate(currencykey) > 0, );

        delete _rates[currencykey][currentroundforrate[currencykey]];

        currentroundforrate[currencykey];

        emit ratedeleted(currencykey);
    }

    function setinversepricing(
        bytes32 currencykey,
        uint entrypoint,
        uint upperlimit,
        uint lowerlimit,
        bool freezeatupperlimit,
        bool freezeatlowerlimit
    ) external onlyowner {
        
        require(lowerlimit > 0, );
        require(upperlimit > entrypoint, );
        require(upperlimit < entrypoint.mul(2), );
        require(lowerlimit < entrypoint, );

        require(!(freezeatupperlimit && freezeatlowerlimit), );

        inversepricing storage inverse = inversepricing[currencykey];
        if (inverse.entrypoint == 0) {
            
            invertedkeys.push(currencykey);
        }
        inverse.entrypoint = entrypoint;
        inverse.upperlimit = upperlimit;
        inverse.lowerlimit = lowerlimit;

        if (freezeatupperlimit || freezeatlowerlimit) {
            
            
            

            inverse.frozenatupperlimit = freezeatupperlimit;
            inverse.frozenatlowerlimit = freezeatlowerlimit;
            emit inversepricefrozen(currencykey, freezeatupperlimit ? upperlimit : lowerlimit, msg.sender);
        } else {
            
            inverse.frozenatupperlimit = false;
            inverse.frozenatlowerlimit = false;
        }

        
        uint rate = _getrate(currencykey);
        if (rate > 0) {
            exchanger().setlastexchangerateforsynth(currencykey, rate);
        }

        emit inversepriceconfigured(currencykey, entrypoint, upperlimit, lowerlimit);
    }

    function removeinversepricing(bytes32 currencykey) external onlyowner {
        require(inversepricing[currencykey].entrypoint > 0, );

        delete inversepricing[currencykey];

        
        bool wasremoved = removefromarray(currencykey, invertedkeys);

        if (wasremoved) {
            emit inversepriceconfigured(currencykey, 0, 0, 0);
        }
    }

    function addaggregator(bytes32 currencykey, address aggregatoraddress) external onlyowner {
        aggregatorv2v3interface aggregator = aggregatorv2v3interface(aggregatoraddress);
        
        

        require(aggregator.latestround() >= 0, );
        uint8 decimals = aggregator.decimals();
        require(decimals <= 18, );
        if (address(aggregators[currencykey]) == address(0)) {
            aggregatorkeys.push(currencykey);
        }
        aggregators[currencykey] = aggregator;
        currencykeydecimals[currencykey] = decimals;
        emit aggregatoradded(currencykey, address(aggregator));
    }

    function removeaggregator(bytes32 currencykey) external onlyowner {
        address aggregator = address(aggregators[currencykey]);
        require(aggregator != address(0), );
        delete aggregators[currencykey];
        delete currencykeydecimals[currencykey];

        bool wasremoved = removefromarray(currencykey, aggregatorkeys);

        if (wasremoved) {
            emit aggregatorremoved(currencykey, aggregator);
        }
    }

    
    function freezerate(bytes32 currencykey) external {
        inversepricing storage inverse = inversepricing[currencykey];
        require(inverse.entrypoint > 0, );
        require(!inverse.frozenatupperlimit && !inverse.frozenatlowerlimit, );

        uint rate = _getrate(currencykey);

        if (rate > 0 && (rate >= inverse.upperlimit || rate <= inverse.lowerlimit)) {
            inverse.frozenatupperlimit = (rate == inverse.upperlimit);
            inverse.frozenatlowerlimit = (rate == inverse.lowerlimit);
            emit inversepricefrozen(currencykey, rate, msg.sender);
        } else {
            revert();
        }
    }

    

    
    function canfreezerate(bytes32 currencykey) external view returns (bool) {
        inversepricing memory inverse = inversepricing[currencykey];
        if (inverse.entrypoint == 0 || inverse.frozenatupperlimit || inverse.frozenatlowerlimit) {
            return false;
        } else {
            uint rate = _getrate(currencykey);
            return (rate > 0 && (rate >= inverse.upperlimit || rate <= inverse.lowerlimit));
        }
    }

    function currenciesusingaggregator(address aggregator) external view returns (bytes32[] memory currencies) {
        uint count = 0;
        currencies = new bytes32[](aggregatorkeys.length);
        for (uint i = 0; i < aggregatorkeys.length; i++) {
            bytes32 currencykey = aggregatorkeys[i];
            if (address(aggregators[currencykey]) == aggregator) {
                currencies[count++] = currencykey;
            }
        }
    }

    function ratestaleperiod() external view returns (uint) {
        return getratestaleperiod();
    }

    function aggregatorwarningflags() external view returns (address) {
        return getaggregatorwarningflags();
    }

    function rateandupdatedtime(bytes32 currencykey) external view returns (uint rate, uint time) {
        rateandupdatedtime memory rateandtime = _getrateandupdatedtime(currencykey);
        return (rateandtime.rate, rateandtime.time);
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
            (, nexttimestamp) = _getrateandtimestampatround(currencykey, roundid + 1);
            
            if (nexttimestamp == 0 || nexttimestamp > startingtimestamp + timediff) {
                return roundid;
            }
            roundid++;
        }
        return roundid;
    }

    function getcurrentroundid(bytes32 currencykey) external view returns (uint) {
        return _getcurrentroundid(currencykey);
    }

    function effectivevalueatround(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        uint roundidforsrc,
        uint roundidfordest
    ) external view returns (uint value) {
        
        if (sourcecurrencykey == destinationcurrencykey) return sourceamount;

        (uint srcrate, ) = _getrateandtimestampatround(sourcecurrencykey, roundidforsrc);
        (uint destrate, ) = _getrateandtimestampatround(destinationcurrencykey, roundidfordest);
        if (destrate == 0) {
            
            
            return 0;
        }
        
        value = sourceamount.multiplydecimalround(srcrate).dividedecimalround(destrate);
    }

    function rateandtimestampatround(bytes32 currencykey, uint roundid) external view returns (uint rate, uint time) {
        return _getrateandtimestampatround(currencykey, roundid);
    }

    function lastrateupdatetimes(bytes32 currencykey) external view returns (uint256) {
        return _getupdatedtime(currencykey);
    }

    function lastrateupdatetimesforcurrencies(bytes32[] calldata currencykeys) external view returns (uint[] memory) {
        uint[] memory lastupdatetimes = new uint[](currencykeys.length);

        for (uint i = 0; i < currencykeys.length; i++) {
            lastupdatetimes[i] = _getupdatedtime(currencykeys[i]);
        }

        return lastupdatetimes;
    }

    function effectivevalue(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external view returns (uint value) {
        (value, , ) = _effectivevalueandrates(sourcecurrencykey, sourceamount, destinationcurrencykey);
    }

    function effectivevalueandrates(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    )
        external
        view
        returns (
            uint value,
            uint sourcerate,
            uint destinationrate
        )
    {
        return _effectivevalueandrates(sourcecurrencykey, sourceamount, destinationcurrencykey);
    }

    function rateforcurrency(bytes32 currencykey) external view returns (uint) {
        return _getrateandupdatedtime(currencykey).rate;
    }

    function ratesandupdatedtimeforcurrencylastnrounds(bytes32 currencykey, uint numrounds)
        external
        view
        returns (uint[] memory rates, uint[] memory times)
    {
        rates = new uint[](numrounds);
        times = new uint[](numrounds);

        uint roundid = _getcurrentroundid(currencykey);
        for (uint i = 0; i < numrounds; i++) {
            (rates[i], times[i]) = _getrateandtimestampatround(currencykey, roundid);
            if (roundid == 0) {
                
                return (rates, times);
            } else {
                roundid;
            }
        }
    }

    function ratesforcurrencies(bytes32[] calldata currencykeys) external view returns (uint[] memory) {
        uint[] memory _localrates = new uint[](currencykeys.length);

        for (uint i = 0; i < currencykeys.length; i++) {
            _localrates[i] = _getrate(currencykeys[i]);
        }

        return _localrates;
    }

    function ratesandinvalidforcurrencies(bytes32[] calldata currencykeys)
        external
        view
        returns (uint[] memory rates, bool anyrateinvalid)
    {
        rates = new uint[](currencykeys.length);

        uint256 _ratestaleperiod = getratestaleperiod();

        
        bool[] memory flaglist = getflagsforrates(currencykeys);

        for (uint i = 0; i < currencykeys.length; i++) {
            
            rateandupdatedtime memory rateentry = _getrateandupdatedtime(currencykeys[i]);
            rates[i] = rateentry.rate;
            if (!anyrateinvalid && currencykeys[i] != ) {
                anyrateinvalid = flaglist[i] || _rateisstalewithtime(_ratestaleperiod, rateentry.time);
            }
        }
    }

    function rateisstale(bytes32 currencykey) external view returns (bool) {
        return _rateisstale(currencykey, getratestaleperiod());
    }

    function rateisfrozen(bytes32 currencykey) external view returns (bool) {
        return _rateisfrozen(currencykey);
    }

    function rateisinvalid(bytes32 currencykey) external view returns (bool) {
        return
            _rateisstale(currencykey, getratestaleperiod()) ||
            _rateisflagged(currencykey, flagsinterface(getaggregatorwarningflags()));
    }

    function rateisflagged(bytes32 currencykey) external view returns (bool) {
        return _rateisflagged(currencykey, flagsinterface(getaggregatorwarningflags()));
    }

    function anyrateisinvalid(bytes32[] calldata currencykeys) external view returns (bool) {
        

        uint256 _ratestaleperiod = getratestaleperiod();
        bool[] memory flaglist = getflagsforrates(currencykeys);

        for (uint i = 0; i < currencykeys.length; i++) {
            if (flaglist[i] || _rateisstale(currencykeys[i], _ratestaleperiod)) {
                return true;
            }
        }

        return false;
    }

    

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(requireandgetaddress(contract_exchanger, ));
    }

    function getflagsforrates(bytes32[] memory currencykeys) internal view returns (bool[] memory flaglist) {
        flagsinterface _flags = flagsinterface(getaggregatorwarningflags());

        
        if (_flags != flagsinterface(0)) {
            address[] memory _aggregators = new address[](currencykeys.length);

            for (uint i = 0; i < currencykeys.length; i++) {
                _aggregators[i] = address(aggregators[currencykeys[i]]);
            }

            flaglist = _flags.getflags(_aggregators);
        } else {
            flaglist = new bool[](currencykeys.length);
        }
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

            
            if (timesent < _getupdatedtime(currencykey)) {
                continue;
            }

            
            _setrate(currencykey, newrates[i], timesent);
        }

        emit ratesupdated(currencykeys, newrates);

        return true;
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

    function _rateorinverted(bytes32 currencykey, uint rate) internal view returns (uint newrate) {
        
        inversepricing memory inverse = inversepricing[currencykey];
        if (inverse.entrypoint == 0 || rate == 0) {
            
            
            
            return rate;
        }

        newrate = rate;

        
        if (inverse.frozenatupperlimit) {
            newrate = inverse.upperlimit;
        } else if (inverse.frozenatlowerlimit) {
            newrate = inverse.lowerlimit;
        } else {
            
            uint doubleentrypoint = inverse.entrypoint.mul(2);
            if (doubleentrypoint <= rate) {
                
                
                
                newrate = 0;
            } else {
                newrate = doubleentrypoint.sub(rate);
            }

            
            if (newrate >= inverse.upperlimit) {
                newrate = inverse.upperlimit;
            } else if (newrate <= inverse.lowerlimit) {
                newrate = inverse.lowerlimit;
            }
        }
    }

    function _formataggregatoranswer(bytes32 currencykey, int256 rate) internal view returns (uint) {
        if (currencykeydecimals[currencykey] > 0) {
            uint multiplier = 10**uint(18  currencykeydecimals[currencykey]);
            return uint(rate * int(multiplier));
        }
        return uint(rate);
    }

    function _getrateandupdatedtime(bytes32 currencykey) internal view returns (rateandupdatedtime memory) {
        aggregatorv2v3interface aggregator = aggregators[currencykey];

        if (aggregator != aggregatorv2v3interface(0)) {
            (, int256 answer, , uint256 updatedat, ) = aggregator.latestrounddata();
            return
                rateandupdatedtime({
                    rate: uint216(_rateorinverted(currencykey, _formataggregatoranswer(currencykey, answer))),
                    time: uint40(updatedat)
                });
        } else {
            rateandupdatedtime memory entry = _rates[currencykey][currentroundforrate[currencykey]];

            return rateandupdatedtime({rate: uint216(_rateorinverted(currencykey, entry.rate)), time: entry.time});
        }
    }

    function _getcurrentroundid(bytes32 currencykey) internal view returns (uint) {
        aggregatorv2v3interface aggregator = aggregators[currencykey];

        if (aggregator != aggregatorv2v3interface(0)) {
            return aggregator.latestround();
        } else {
            return currentroundforrate[currencykey];
        }
    }

    function _getrateandtimestampatround(bytes32 currencykey, uint roundid) internal view returns (uint rate, uint time) {
        aggregatorv2v3interface aggregator = aggregators[currencykey];

        if (aggregator != aggregatorv2v3interface(0)) {
            (, int256 answer, , uint256 updatedat, ) = aggregator.getrounddata(uint80(roundid));
            return (_rateorinverted(currencykey, _formataggregatoranswer(currencykey, answer)), updatedat);
        } else {
            rateandupdatedtime memory update = _rates[currencykey][roundid];
            return (_rateorinverted(currencykey, update.rate), update.time);
        }
    }

    function _getrate(bytes32 currencykey) internal view returns (uint256) {
        return _getrateandupdatedtime(currencykey).rate;
    }

    function _getupdatedtime(bytes32 currencykey) internal view returns (uint256) {
        return _getrateandupdatedtime(currencykey).time;
    }

    function _effectivevalueandrates(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    )
        internal
        view
        returns (
            uint value,
            uint sourcerate,
            uint destinationrate
        )
    {
        sourcerate = _getrate(sourcecurrencykey);
        
        if (sourcecurrencykey == destinationcurrencykey) {
            destinationrate = sourcerate;
            value = sourceamount;
        } else {
            
            destinationrate = _getrate(destinationcurrencykey);
            
            if (destinationrate > 0) {
                value = sourceamount.multiplydecimalround(sourcerate).dividedecimalround(destinationrate);
            }
        }
    }

    function _rateisstale(bytes32 currencykey, uint _ratestaleperiod) internal view returns (bool) {
        
        if (currencykey == ) return false;

        return _rateisstalewithtime(_ratestaleperiod, _getupdatedtime(currencykey));
    }

    function _rateisstalewithtime(uint _ratestaleperiod, uint _time) internal view returns (bool) {
        return _time.add(_ratestaleperiod) < now;
    }

    function _rateisfrozen(bytes32 currencykey) internal view returns (bool) {
        inversepricing memory inverse = inversepricing[currencykey];
        return inverse.frozenatupperlimit || inverse.frozenatlowerlimit;
    }

    function _rateisflagged(bytes32 currencykey, flagsinterface flags) internal view returns (bool) {
        
        if (currencykey == ) return false;
        address aggregator = address(aggregators[currencykey]);
        
        if (aggregator == address(0) || flags == flagsinterface(0)) {
            return false;
        }
        return flags.getflag(aggregator);
    }

    

    modifier onlyoracle {
        require(msg.sender == oracle, );
        _;
    }

    

    event oracleupdated(address neworacle);
    event ratesupdated(bytes32[] currencykeys, uint[] newrates);
    event ratedeleted(bytes32 currencykey);
    event inversepriceconfigured(bytes32 currencykey, uint entrypoint, uint upperlimit, uint lowerlimit);
    event inversepricefrozen(bytes32 currencykey, uint rate, address initiator);
    event aggregatoradded(bytes32 currencykey, address aggregator);
    event aggregatorremoved(bytes32 currencykey, address aggregator);
}
