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


contract binaryoptionmarket is owned, mixinresolver, ibinaryoptionmarket {
    

    using safemath for uint;
    using safedecimalmath for uint;

    

    struct options {
        binaryoption long;
        binaryoption short;
    }

    struct prices {
        uint long;
        uint short;
    }

    struct times {
        uint biddingend;
        uint maturity;
        uint expiry;
    }

    struct oracledetails {
        bytes32 key;
        uint strikeprice;
        uint finalprice;
    }

    

    options public options;
    prices public prices;
    times public times;
    oracledetails public oracledetails;
    binaryoptionmarketmanager.fees public fees;
    binaryoptionmarketmanager.creatorlimits public creatorlimits;

    
    
    uint public deposited;
    address public creator;
    bool public resolved;

    uint internal _feemultiplier;

    

    bytes32 internal constant contract_systemstatus = ;
    bytes32 internal constant contract_exrates = ;
    bytes32 internal constant contract_synthsusd = ;
    bytes32 internal constant contract_feepool = ;

    bytes32[24] internal addressestocache = [contract_systemstatus, contract_exrates, contract_synthsusd, contract_feepool];

    

    constructor(
        address _owner,
        address _creator,
        uint[2] memory _creatorlimits, 
        bytes32 _oraclekey,
        uint _strikeprice,
        uint[3] memory _times, 
        uint[2] memory _bids, 
        uint[3] memory _fees 
    )
        public
        owned(_owner)
        mixinresolver(_owner, addressestocache) 
    {
        creator = _creator;
        creatorlimits = binaryoptionmarketmanager.creatorlimits(_creatorlimits[0], _creatorlimits[1]);

        oracledetails = oracledetails(_oraclekey, _strikeprice, 0);
        times = times(_times[0], _times[1], _times[2]);

        (uint longbid, uint shortbid) = (_bids[0], _bids[1]);
        _checkcreatorlimits(longbid, shortbid);

        
        
        
        uint initialdeposit = longbid.add(shortbid);
        deposited = initialdeposit;

        (uint poolfee, uint creatorfee) = (_fees[0], _fees[1]);
        fees = binaryoptionmarketmanager.fees(poolfee, creatorfee, _fees[2]);
        _feemultiplier = safedecimalmath.unit().sub(poolfee.add(creatorfee));

        
        _updateprices(longbid, shortbid, initialdeposit);

        
        options.long = new binaryoption(_creator, longbid);
        options.short = new binaryoption(_creator, shortbid);
    }

    

    

    function _systemstatus() internal view returns (isystemstatus) {
        return isystemstatus(requireandgetaddress(contract_systemstatus, ));
    }

    function _exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    function _susd() internal view returns (ierc20) {
        return ierc20(requireandgetaddress(contract_synthsusd, ));
    }

    function _feepool() internal view returns (ifeepool) {
        return ifeepool(requireandgetaddress(contract_feepool, ));
    }

    function _manager() internal view returns (binaryoptionmarketmanager) {
        return binaryoptionmarketmanager(owner);
    }

    

    function _biddingended() internal view returns (bool) {
        return times.biddingend < now;
    }

    function _matured() internal view returns (bool) {
        return times.maturity < now;
    }

    function _expired() internal view returns (bool) {
        return resolved && (times.expiry < now || deposited == 0);
    }

    function phase() external view returns (phase) {
        if (!_biddingended()) {
            return phase.bidding;
        }
        if (!_matured()) {
            return phase.trading;
        }
        if (!_expired()) {
            return phase.maturity;
        }
        return phase.expiry;
    }

    

    function _oraclepriceandtimestamp() internal view returns (uint price, uint updatedat) {
        return _exchangerates().rateandupdatedtime(oracledetails.key);
    }

    function oraclepriceandtimestamp() external view returns (uint price, uint updatedat) {
        return _oraclepriceandtimestamp();
    }

    function _isfreshpriceupdatetime(uint timestamp) internal view returns (bool) {
        (uint maxoraclepriceage, , ) = _manager().durations();
        return (times.maturity.sub(maxoraclepriceage)) <= timestamp;
    }

    function canresolve() external view returns (bool) {
        (, uint updatedat) = _oraclepriceandtimestamp();
        return !resolved && _matured() && _isfreshpriceupdatetime(updatedat);
    }

    function _result() internal view returns (side) {
        uint price;
        if (resolved) {
            price = oracledetails.finalprice;
        } else {
            (price, ) = _oraclepriceandtimestamp();
        }

        return oracledetails.strikeprice <= price ? side.long : side.short;
    }

    function result() external view returns (side) {
        return _result();
    }

    

    function _computeprices(
        uint longbids,
        uint shortbids,
        uint _deposited
    ) internal view returns (uint long, uint short) {
        require(longbids != 0 && shortbids != 0, );
        uint optionsperside = _exercisabledeposits(_deposited);

        
        
        return (longbids.dividedecimalround(optionsperside), shortbids.dividedecimalround(optionsperside));
    }

    function senderpriceandexercisabledeposits() external view returns (uint price, uint exercisable) {
        exercisable = _exercisabledeposits(deposited);
        if (msg.sender == address(options.long)) {
            price = prices.long;
        } else if (msg.sender == address(options.short)) {
            price = prices.short;
        } else {
            revert();
        }
    }

    function pricesafterbidorrefund(
        side side,
        uint value,
        bool refund
    ) external view returns (uint long, uint short) {
        (uint longtotalbids, uint shorttotalbids) = _totalbids();
        
        function(uint, uint) pure returns (uint) operation = refund ? safemath.sub : safemath.add;

        if (side == side.long) {
            longtotalbids = operation(longtotalbids, value);
        } else {
            shorttotalbids = operation(shorttotalbids, value);
        }

        if (refund) {
            value = value.multiplydecimalround(safedecimalmath.unit().sub(fees.refundfee));
        }
        return _computeprices(longtotalbids, shorttotalbids, operation(deposited, value));
    }

    
    function bidorrefundforprice(
        side bidside,
        side priceside,
        uint price,
        bool refund
    ) external view returns (uint) {
        uint adjustedprice = price.multiplydecimalround(_feemultiplier);
        uint bids = _option(priceside).totalbids();
        uint _deposited = deposited;
        uint unit = safedecimalmath.unit();
        uint refundfeemultiplier = unit.sub(fees.refundfee);

        if (bidside == priceside) {
            uint depositedbyprice = _deposited.multiplydecimalround(adjustedprice);

            
            
            if (refund) {
                (depositedbyprice, bids) = (bids, depositedbyprice);
                adjustedprice = adjustedprice.multiplydecimalround(refundfeemultiplier);
            }

            
            return _subtozero(depositedbyprice, bids).dividedecimalround(unit.sub(adjustedprice));
        } else {
            uint bidsperprice = bids.dividedecimalround(adjustedprice);

            
            if (refund) {
                (bidsperprice, _deposited) = (_deposited, bidsperprice);
            }

            uint value = _subtozero(bidsperprice, _deposited);
            return refund ? value.dividedecimalround(refundfeemultiplier) : value;
        }
    }

    

    function _bidsof(address account) internal view returns (uint long, uint short) {
        return (options.long.bidof(account), options.short.bidof(account));
    }

    function bidsof(address account) external view returns (uint long, uint short) {
        return _bidsof(account);
    }

    function _totalbids() internal view returns (uint long, uint short) {
        return (options.long.totalbids(), options.short.totalbids());
    }

    function totalbids() external view returns (uint long, uint short) {
        return _totalbids();
    }

    function _claimablebalancesof(address account) internal view returns (uint long, uint short) {
        return (options.long.claimablebalanceof(account), options.short.claimablebalanceof(account));
    }

    function claimablebalancesof(address account) external view returns (uint long, uint short) {
        return _claimablebalancesof(account);
    }

    function totalclaimablesupplies() external view returns (uint long, uint short) {
        return (options.long.totalclaimablesupply(), options.short.totalclaimablesupply());
    }

    function _balancesof(address account) internal view returns (uint long, uint short) {
        return (options.long.balanceof(account), options.short.balanceof(account));
    }

    function balancesof(address account) external view returns (uint long, uint short) {
        return _balancesof(account);
    }

    function totalsupplies() external view returns (uint long, uint short) {
        return (options.long.totalsupply(), options.short.totalsupply());
    }

    function _exercisabledeposits(uint _deposited) internal view returns (uint) {
        
        return resolved ? _deposited : _deposited.multiplydecimalround(_feemultiplier);
    }

    function exercisabledeposits() external view returns (uint) {
        return _exercisabledeposits(deposited);
    }

    

    function _chooseside(
        side side,
        uint longvalue,
        uint shortvalue
    ) internal pure returns (uint) {
        if (side == side.long) {
            return longvalue;
        }
        return shortvalue;
    }

    function _option(side side) internal view returns (binaryoption) {
        if (side == side.long) {
            return options.long;
        }
        return options.short;
    }

    
    function _subtozero(uint a, uint b) internal pure returns (uint) {
        return a < b ? 0 : a.sub(b);
    }

    function _checkcreatorlimits(uint longbid, uint shortbid) internal view {
        uint totalbid = longbid.add(shortbid);
        require(creatorlimits.capitalrequirement <= totalbid, );
        uint skewlimit = creatorlimits.skewlimit;
        require(
            skewlimit <= longbid.dividedecimal(totalbid) && skewlimit <= shortbid.dividedecimal(totalbid),
            
        );
    }

    function _incrementdeposited(uint value) internal returns (uint _deposited) {
        _deposited = deposited.add(value);
        deposited = _deposited;
        _manager().incrementtotaldeposited(value);
    }

    function _decrementdeposited(uint value) internal returns (uint _deposited) {
        _deposited = deposited.sub(value);
        deposited = _deposited;
        _manager().decrementtotaldeposited(value);
    }

    function _requiremanagernotpaused() internal view {
        require(!_manager().paused(), );
    }

    function requireactiveandunpaused() external view {
        _systemstatus().requiresystemactive();
        _requiremanagernotpaused();
    }

    

    

    function _updateprices(
        uint longbids,
        uint shortbids,
        uint _deposited
    ) internal {
        (uint256 longprice, uint256 shortprice) = _computeprices(longbids, shortbids, _deposited);
        prices = prices(longprice, shortprice);
        emit pricesupdated(longprice, shortprice);
    }

    function bid(side side, uint value) external duringbidding {
        if (value == 0) {
            return;
        }

        _option(side).bid(msg.sender, value);
        emit bid(side, msg.sender, value);

        uint _deposited = _incrementdeposited(value);
        _susd().transferfrom(msg.sender, address(this), value);

        (uint longtotalbids, uint shorttotalbids) = _totalbids();
        _updateprices(longtotalbids, shorttotalbids, _deposited);
    }

    function refund(side side, uint value) external duringbidding returns (uint refundminusfee) {
        if (value == 0) {
            return 0;
        }

        
        if (msg.sender == creator) {
            (uint thisbid, uint thatbid) = _bidsof(msg.sender);
            if (side == side.short) {
                (thisbid, thatbid) = (thatbid, thisbid);
            }
            _checkcreatorlimits(thisbid.sub(value), thatbid);
        }

        
        
        refundminusfee = value.multiplydecimalround(safedecimalmath.unit().sub(fees.refundfee));

        _option(side).refund(msg.sender, value);
        emit refund(side, msg.sender, refundminusfee, value.sub(refundminusfee));

        uint _deposited = _decrementdeposited(refundminusfee);
        _susd().transfer(msg.sender, refundminusfee);

        (uint longtotalbids, uint shorttotalbids) = _totalbids();
        _updateprices(longtotalbids, shorttotalbids, _deposited);
    }

    

    function resolve() external onlyowner aftermaturity systemactive managernotpaused {
        require(!resolved, );

        
        
        (uint price, uint updatedat) = _oraclepriceandtimestamp();
        require(_isfreshpriceupdatetime(updatedat), );

        oracledetails.finalprice = price;
        resolved = true;

        
        
        
        ierc20 susd = _susd();

        uint _deposited = deposited;
        uint poolfees = _deposited.multiplydecimalround(fees.poolfee);
        uint creatorfees = _deposited.multiplydecimalround(fees.creatorfee);
        _decrementdeposited(creatorfees.add(poolfees));
        susd.transfer(_feepool().fee_address(), poolfees);
        susd.transfer(creator, creatorfees);

        emit marketresolved(_result(), price, updatedat, deposited, poolfees, creatorfees);
    }

    

    function _claimoptions()
        internal
        systemactive
        managernotpaused
        afterbidding
        returns (uint longclaimed, uint shortclaimed)
    {
        uint exercisable = _exercisabledeposits(deposited);
        uint longoptions = options.long.claim(msg.sender, prices.long, exercisable);
        uint shortoptions = options.short.claim(msg.sender, prices.short, exercisable);

        require(longoptions != 0 || shortoptions != 0, );
        emit optionsclaimed(msg.sender, longoptions, shortoptions);
        return (longoptions, shortoptions);
    }

    function claimoptions() external returns (uint longclaimed, uint shortclaimed) {
        return _claimoptions();
    }

    function exerciseoptions() external returns (uint) {
        
        if (!resolved) {
            _manager().resolvemarket(address(this));
        }

        
        (uint claimablelong, uint claimableshort) = _claimablebalancesof(msg.sender);
        if (claimablelong != 0 || claimableshort != 0) {
            _claimoptions();
        }

        
        (uint longbalance, uint shortbalance) = _balancesof(msg.sender);
        require(longbalance != 0 || shortbalance != 0, );

        
        if (longbalance != 0) {
            options.long.exercise(msg.sender);
        }
        if (shortbalance != 0) {
            options.short.exercise(msg.sender);
        }

        
        uint payout = _chooseside(_result(), longbalance, shortbalance);
        emit optionsexercised(msg.sender, payout);
        if (payout != 0) {
            _decrementdeposited(payout);
            _susd().transfer(msg.sender, payout);
        }
        return payout;
    }

    

    function expire(address payable beneficiary) external onlyowner {
        require(_expired(), );

        uint _deposited = deposited;
        if (_deposited != 0) {
            _decrementdeposited(_deposited);
        }
        
        
        ierc20 susd = _susd();
        uint balance = susd.balanceof(address(this));
        if (balance != 0) {
            susd.transfer(beneficiary, balance);
        }

        
        options.long.expire(beneficiary);
        options.short.expire(beneficiary);

        
        selfdestruct(beneficiary);
    }

    

    modifier duringbidding() {
        require(!_biddingended(), );
        _;
    }

    modifier afterbidding() {
        require(_biddingended(), );
        _;
    }

    modifier aftermaturity() {
        require(_matured(), );
        _;
    }

    modifier systemactive() {
        _systemstatus().requiresystemactive();
        _;
    }

    modifier managernotpaused() {
        _requiremanagernotpaused();
        _;
    }

    

    event bid(side side, address indexed account, uint value);
    event refund(side side, address indexed account, uint value, uint fee);
    event pricesupdated(uint longprice, uint shortprice);
    event marketresolved(
        side result,
        uint oracleprice,
        uint oracletimestamp,
        uint deposited,
        uint poolfees,
        uint creatorfees
    );
    event optionsclaimed(address indexed account, uint longoptions, uint shortoptions);
    event optionsexercised(address indexed account, uint value);
}
