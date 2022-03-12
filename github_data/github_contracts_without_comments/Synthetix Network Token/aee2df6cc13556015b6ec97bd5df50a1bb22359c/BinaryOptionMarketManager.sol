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
import ;
import ;
import ;
import ;


contract binaryoptionmarketmanager is owned, pausable, selfdestructible, mixinresolver, ibinaryoptionmarketmanager {
    

    using safemath for uint;
    using addresslistlib for addresslistlib.addresslist;

    

    struct fees {
        uint poolfee;
        uint creatorfee;
        uint refundfee;
    }

    struct durations {
        uint maxoraclepriceage;
        uint expiryduration;
        uint maxtimetomaturity;
    }

    struct creatorlimits {
        uint capitalrequirement;
        uint skewlimit;
    }

    

    fees public fees;
    durations public durations;
    creatorlimits public creatorlimits;

    bool public marketcreationenabled = true;
    uint public totaldeposited;

    addresslistlib.addresslist internal _activemarkets;
    addresslistlib.addresslist internal _maturedmarkets;

    binaryoptionmarketmanager internal _migratingmanager;

    

    bytes32 internal constant contract_systemstatus = ;
    bytes32 internal constant contract_synthsusd = ;
    bytes32 internal constant contract_exrates = ;
    bytes32 internal constant contract_binaryoptionmarketfactory = ;

    bytes32[24] internal addressestocache = [
        contract_systemstatus,
        contract_synthsusd,
        contract_exrates,
        contract_binaryoptionmarketfactory
    ];

    

    constructor(
        address _owner,
        address _resolver,
        uint _maxoraclepriceage,
        uint _expiryduration,
        uint _maxtimetomaturity,
        uint _creatorcapitalrequirement,
        uint _creatorskewlimit,
        uint _poolfee,
        uint _creatorfee,
        uint _refundfee
    ) public owned(_owner) pausable() selfdestructible() mixinresolver(_resolver, addressestocache) {
        
        owner = msg.sender;
        setexpiryduration(_expiryduration);
        setmaxoraclepriceage(_maxoraclepriceage);
        setmaxtimetomaturity(_maxtimetomaturity);
        setcreatorcapitalrequirement(_creatorcapitalrequirement);
        setcreatorskewlimit(_creatorskewlimit);
        setpoolfee(_poolfee);
        setcreatorfee(_creatorfee);
        setrefundfee(_refundfee);
        owner = _owner;
    }

    

    

    function _systemstatus() internal view returns (isystemstatus) {
        return isystemstatus(requireandgetaddress(contract_systemstatus, ));
    }

    function _susd() internal view returns (ierc20) {
        return ierc20(requireandgetaddress(contract_synthsusd, ));
    }

    function _exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    function _factory() internal view returns (binaryoptionmarketfactory) {
        return
            binaryoptionmarketfactory(
                requireandgetaddress(contract_binaryoptionmarketfactory, )
            );
    }

    

    function _isknownmarket(address candidate) internal view returns (bool) {
        return _activemarkets.contains(candidate) || _maturedmarkets.contains(candidate);
    }

    function numactivemarkets() external view returns (uint) {
        return _activemarkets.elements.length;
    }

    function activemarkets(uint index, uint pagesize) external view returns (address[] memory) {
        return _activemarkets.getpage(index, pagesize);
    }

    function nummaturedmarkets() external view returns (uint) {
        return _maturedmarkets.elements.length;
    }

    function maturedmarkets(uint index, uint pagesize) external view returns (address[] memory) {
        return _maturedmarkets.getpage(index, pagesize);
    }

    function _isvalidkey(bytes32 oraclekey) internal view returns (bool) {
        iexchangerates exchangerates = _exchangerates();

        
        if (exchangerates.rateforcurrency(oraclekey) != 0) {
            
            if (oraclekey == ) {
                return false;
            }

            
            (uint entrypoint, , , ) = exchangerates.inversepricing(oraclekey);
            if (entrypoint != 0) {
                return false;
            }

            return true;
        }

        return false;
    }

    

    

    function setmaxoraclepriceage(uint _maxoraclepriceage) public onlyowner {
        durations.maxoraclepriceage = _maxoraclepriceage;
        emit maxoraclepriceageupdated(_maxoraclepriceage);
    }

    function setexpiryduration(uint _expiryduration) public onlyowner {
        durations.expiryduration = _expiryduration;
        emit expirydurationupdated(_expiryduration);
    }

    function setmaxtimetomaturity(uint _maxtimetomaturity) public onlyowner {
        durations.maxtimetomaturity = _maxtimetomaturity;
        emit maxtimetomaturityupdated(_maxtimetomaturity);
    }

    function setpoolfee(uint _poolfee) public onlyowner {
        uint totalfee = _poolfee + fees.creatorfee;
        require(totalfee < safedecimalmath.unit(), );
        require(0 < totalfee, );
        fees.poolfee = _poolfee;
        emit poolfeeupdated(_poolfee);
    }

    function setcreatorfee(uint _creatorfee) public onlyowner {
        uint totalfee = _creatorfee + fees.poolfee;
        require(totalfee < safedecimalmath.unit(), );
        require(0 < totalfee, );
        fees.creatorfee = _creatorfee;
        emit creatorfeeupdated(_creatorfee);
    }

    function setrefundfee(uint _refundfee) public onlyowner {
        require(_refundfee <= safedecimalmath.unit(), );
        fees.refundfee = _refundfee;
        emit refundfeeupdated(_refundfee);
    }

    function setcreatorcapitalrequirement(uint _creatorcapitalrequirement) public onlyowner {
        creatorlimits.capitalrequirement = _creatorcapitalrequirement;
        emit creatorcapitalrequirementupdated(_creatorcapitalrequirement);
    }

    function setcreatorskewlimit(uint _creatorskewlimit) public onlyowner {
        require(_creatorskewlimit <= safedecimalmath.unit(), );
        creatorlimits.skewlimit = _creatorskewlimit;
        emit creatorskewlimitupdated(_creatorskewlimit);
    }

    

    function incrementtotaldeposited(uint delta) external onlyactivemarkets notpaused {
        _systemstatus().requiresystemactive();
        totaldeposited = totaldeposited.add(delta);
    }

    function decrementtotaldeposited(uint delta) external onlyknownmarkets notpaused {
        _systemstatus().requiresystemactive();
        
        
        
        totaldeposited = totaldeposited.sub(delta);
    }

    

    function createmarket(
        bytes32 oraclekey,
        uint strikeprice,
        bool refundsenabled,
        uint[2] calldata times, 
        uint[2] calldata bids 
    )
        external
        notpaused
        returns (
            ibinaryoptionmarket 
        )
    {
        _systemstatus().requiresystemactive();
        require(marketcreationenabled, );
        require(_isvalidkey(oraclekey), );

        (uint biddingend, uint maturity) = (times[0], times[1]);
        require(maturity <= now + durations.maxtimetomaturity, );
        uint expiry = maturity.add(durations.expiryduration);

        uint initialdeposit = bids[0].add(bids[1]);
        require(now < biddingend, );
        require(biddingend < maturity, );
        
        
        

        binaryoptionmarket market = _factory().createmarket(
            msg.sender,
            [creatorlimits.capitalrequirement, creatorlimits.skewlimit],
            oraclekey,
            strikeprice,
            refundsenabled,
            [biddingend, maturity, expiry],
            bids,
            [fees.poolfee, fees.creatorfee, fees.refundfee]
        );
        market.setresolverandsynccache(resolver);
        _activemarkets.push(address(market));

        
        
        totaldeposited = totaldeposited.add(initialdeposit);
        _susd().transferfrom(msg.sender, address(market), initialdeposit);

        emit marketcreated(address(market), msg.sender, oraclekey, strikeprice, biddingend, maturity, expiry);
        return market;
    }

    function resolvemarket(address market) external {
        require(_activemarkets.contains(market), );
        binaryoptionmarket(market).resolve();
        _activemarkets.remove(market);
        _maturedmarkets.push(market);
    }

    function cancelmarket(address market) external notpaused {
        require(_activemarkets.contains(market), );
        address creator = binaryoptionmarket(market).creator();
        require(msg.sender == creator, );
        binaryoptionmarket(market).cancel(msg.sender);
        _activemarkets.remove(market);
        emit marketcancelled(market);
    }

    function expiremarkets(address[] calldata markets) external notpaused {
        for (uint i = 0; i < markets.length; i++) {
            address market = markets[i];

            
            binaryoptionmarket(market).expire(msg.sender);
            
            
            _maturedmarkets.remove(market);
            emit marketexpired(market);
        }
    }

    

    function setresolverandsynccacheonmarkets(addressresolver _resolver, binaryoptionmarket[] calldata marketstosync)
        external
        onlyowner
    {
        for (uint i = 0; i < marketstosync.length; i++) {
            marketstosync[i].setresolverandsynccache(_resolver);
        }
    }

    function setmarketcreationenabled(bool enabled) public onlyowner {
        if (enabled != marketcreationenabled) {
            marketcreationenabled = enabled;
            emit marketcreationenabledupdated(enabled);
        }
    }

    function setmigratingmanager(binaryoptionmarketmanager manager) public onlyowner {
        _migratingmanager = manager;
    }

    function migratemarkets(
        binaryoptionmarketmanager receivingmanager,
        bool active,
        binaryoptionmarket[] calldata marketstomigrate
    ) external onlyowner {
        uint _nummarkets = marketstomigrate.length;
        if (_nummarkets == 0) {
            return;
        }
        addresslistlib.addresslist storage markets = active ? _activemarkets : _maturedmarkets;

        uint runningdeposittotal;
        for (uint i; i < _nummarkets; i++) {
            binaryoptionmarket market = marketstomigrate[i];
            require(_isknownmarket(address(market)), );

            
            markets.remove(address(market));
            runningdeposittotal = runningdeposittotal.add(market.deposited());

            
            market.nominatenewowner(address(receivingmanager));
        }
        
        totaldeposited = totaldeposited.sub(runningdeposittotal);
        emit marketsmigrated(receivingmanager, marketstomigrate);

        
        receivingmanager.receivemarkets(active, marketstomigrate);
    }

    function receivemarkets(bool active, binaryoptionmarket[] calldata marketstoreceive) external {
        require(msg.sender == address(_migratingmanager), );

        uint _nummarkets = marketstoreceive.length;
        if (_nummarkets == 0) {
            return;
        }
        addresslistlib.addresslist storage markets = active ? _activemarkets : _maturedmarkets;

        uint runningdeposittotal;
        for (uint i; i < _nummarkets; i++) {
            binaryoptionmarket market = marketstoreceive[i];
            require(!_isknownmarket(address(market)), );

            market.acceptownership();
            markets.push(address(market));
            
            runningdeposittotal = runningdeposittotal.add(market.deposited());
        }
        totaldeposited = totaldeposited.add(runningdeposittotal);
        emit marketsreceived(_migratingmanager, marketstoreceive);
    }

    

    modifier onlyactivemarkets() {
        require(_activemarkets.contains(msg.sender), );
        _;
    }

    modifier onlyknownmarkets() {
        require(_isknownmarket(msg.sender), );
        _;
    }

    

    event marketcreated(
        address market,
        address indexed creator,
        bytes32 indexed oraclekey,
        uint strikeprice,
        uint biddingenddate,
        uint maturitydate,
        uint expirydate
    );
    event marketexpired(address market);
    event marketcancelled(address market);
    event marketsmigrated(binaryoptionmarketmanager receivingmanager, binaryoptionmarket[] markets);
    event marketsreceived(binaryoptionmarketmanager migratingmanager, binaryoptionmarket[] markets);
    event marketcreationenabledupdated(bool enabled);
    event maxoraclepriceageupdated(uint duration);
    event exercisedurationupdated(uint duration);
    event expirydurationupdated(uint duration);
    event maxtimetomaturityupdated(uint duration);
    event creatorcapitalrequirementupdated(uint value);
    event creatorskewlimitupdated(uint value);
    event poolfeeupdated(uint fee);
    event creatorfeeupdated(uint fee);
    event refundfeeupdated(uint fee);
}
