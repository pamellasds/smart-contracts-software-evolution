

pragma solidity 0.4.24;


import ;
import ;
import ;
import ;



contract havven is externstatetoken {

    

    
    struct issuancedata {
        
        uint currentbalancesum;
        
        uint lastaveragebalance;
        
        uint lastmodified;
    }

    
    mapping(address => issuancedata) public issuancedata;
    
    issuancedata public totalissuancedata;

    
    uint public feeperiodstarttime;
    
    uint public lastfeeperiodstarttime;

    
    uint public feeperiodduration = 4 weeks;
    
    uint constant min_fee_period_duration = 1 days;
    uint constant max_fee_period_duration = 26 weeks;

    
    
    uint public lastfeescollected;

    
    mapping(address => bool) public haswithdrawnfees;

    nomin public nomin;
    havvenescrow public escrow;

    
    address public oracle;
    
    uint public price;
    
    uint public lastpriceupdatetime;
    
    uint public pricestaleperiod = 3 hours;

    
    uint public issuanceratio = unit / 5;
    
    uint constant max_issuance_ratio = unit;

    
    mapping(address => bool) public isissuer;
    
    mapping(address => uint) public nominsissued;

    uint constant havven_supply = 1e8 * unit;
    uint constant oracle_future_limit = 10 minutes;
    string constant token_name = ;
    string constant token_symbol = ;
    
    

    
    constructor(address _proxy, tokenstate _tokenstate, address _owner, address _oracle,
                uint _price, address[] _issuers, havven _oldhavven)
        externstatetoken(_proxy, _tokenstate, token_name, token_symbol, havven_supply, _owner)
        public
    {
        oracle = _oracle;
        price = _price;
        lastpriceupdatetime = now;

        uint i;
        if (_oldhavven == address(0)) {
            feeperiodstarttime = now;
            lastfeeperiodstarttime = now  feeperiodduration;
            for (i = 0; i < _issuers.length; i++) {
                isissuer[_issuers[i]] = true;
            }
        } else {
            feeperiodstarttime = _oldhavven.feeperiodstarttime();
            lastfeeperiodstarttime = _oldhavven.lastfeeperiodstarttime();

            uint cbs;
            uint lab;
            uint lm;
            (cbs, lab, lm) = _oldhavven.totalissuancedata();
            totalissuancedata.currentbalancesum = cbs;
            totalissuancedata.lastaveragebalance = lab;
            totalissuancedata.lastmodified = lm;

            for (i = 0; i < _issuers.length; i++) {
                address issuer = _issuers[i];
                isissuer[issuer] = true;
                uint nomins = _oldhavven.nominsissued(issuer);
                if (nomins == 0) {
                    
                    
                    continue;
                }
                (cbs, lab, lm) = _oldhavven.issuancedata(issuer);
                nominsissued[issuer] = nomins;
                issuancedata[issuer].currentbalancesum = cbs;
                issuancedata[issuer].lastaveragebalance = lab;
                issuancedata[issuer].lastmodified = lm;
            }
        }

    }

    

    
    function setnomin(nomin _nomin)
        external
        optionalproxy_onlyowner
    {
        nomin = _nomin;
        emitnominupdated(_nomin);
    }

    
    function setescrow(havvenescrow _escrow)
        external
        optionalproxy_onlyowner
    {
        escrow = _escrow;
        emitescrowupdated(_escrow);
    }

    
    function setfeeperiodduration(uint duration)
        external
        optionalproxy_onlyowner
    {
        require(min_fee_period_duration <= duration && duration <= max_fee_period_duration,
            );
        feeperiodduration = duration;
        emitfeeperioddurationupdated(duration);
        rolloverfeeperiodifelapsed();
    }

    
    function setoracle(address _oracle)
        external
        optionalproxy_onlyowner
    {
        oracle = _oracle;
        emitoracleupdated(_oracle);
    }

    
    function setpricestaleperiod(uint time)
        external
        optionalproxy_onlyowner
    {
        pricestaleperiod = time;
    }

    
    function setissuanceratio(uint _issuanceratio)
        external
        optionalproxy_onlyowner
    {
        require(_issuanceratio <= max_issuance_ratio, );
        issuanceratio = _issuanceratio;
        emitissuanceratioupdated(_issuanceratio);
    }

    
    function setissuer(address account, bool value)
        external
        optionalproxy_onlyowner
    {
        isissuer[account] = value;
        emitissuersupdated(account, value);
    }

    

    function issuancecurrentbalancesum(address account)
        external
        view
        returns (uint)
    {
        return issuancedata[account].currentbalancesum;
    }

    function issuancelastaveragebalance(address account)
        external
        view
        returns (uint)
    {
        return issuancedata[account].lastaveragebalance;
    }

    function issuancelastmodified(address account)
        external
        view
        returns (uint)
    {
        return issuancedata[account].lastmodified;
    }

    function totalissuancecurrentbalancesum()
        external
        view
        returns (uint)
    {
        return totalissuancedata.currentbalancesum;
    }

    function totalissuancelastaveragebalance()
        external
        view
        returns (uint)
    {
        return totalissuancedata.lastaveragebalance;
    }

    function totalissuancelastmodified()
        external
        view
        returns (uint)
    {
        return totalissuancedata.lastmodified;
    }

    

    
    function transfer(address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;
        require(nominsissued[sender] == 0 || value <= transferablehavvens(sender), );
        
        _transfer_byproxy(sender, to, value);

        return true;
    }

    
    function transferfrom(address from, address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;
        require(nominsissued[from] == 0 || value <= transferablehavvens(from), );
        
        _transferfrom_byproxy(sender, from, to, value);

        return true;
    }

    
    function withdrawfees()
        external
        optionalproxy
    {
        address sender = messagesender;
        rolloverfeeperiodifelapsed();
        
        require(!nomin.frozen(sender), );

        
        updateissuancedata(sender, nominsissued[sender], nomin.totalsupply());

        
        require(!haswithdrawnfees[sender], );

        uint feesowed;
        uint lasttotalissued = totalissuancedata.lastaveragebalance;

        if (lasttotalissued > 0) {
            
            feesowed = safediv_dec(
                safemul_dec(issuancedata[sender].lastaveragebalance, lastfeescollected),
                lasttotalissued
            );
        }

        haswithdrawnfees[sender] = true;

        if (feesowed != 0) {
            nomin.withdrawfees(sender, feesowed);
        }
        emitfeeswithdrawn(messagesender, feesowed);
    }

    
    function updateissuancedata(address account, uint prebalance, uint lasttotalsupply)
        internal
    {
        
        totalissuancedata = computeissuancedata(lasttotalsupply, totalissuancedata);

        if (issuancedata[account].lastmodified < feeperiodstarttime) {
            haswithdrawnfees[account] = false;
        }

        issuancedata[account] = computeissuancedata(prebalance, issuancedata[account]);
    }


    
    function computeissuancedata(uint prebalance, issuancedata preissuance)
        internal
        view
        returns (issuancedata)
    {

        uint currentbalancesum = preissuance.currentbalancesum;
        uint lastaveragebalance = preissuance.lastaveragebalance;
        uint lastmodified = preissuance.lastmodified;

        if (lastmodified < feeperiodstarttime) {
            if (lastmodified < lastfeeperiodstarttime) {
                
                lastaveragebalance = prebalance;
            } else {
                
                
                uint timeuptorollover = feeperiodstarttime  lastmodified;
                uint lastfeeperiodduration = feeperiodstarttime  lastfeeperiodstarttime;
                uint lastbalancesum = safeadd(currentbalancesum, safemul(prebalance, timeuptorollover));
                lastaveragebalance = lastbalancesum / lastfeeperiodduration;
            }
            
            currentbalancesum = safemul(prebalance, now  feeperiodstarttime);
        } else {
            
            currentbalancesum = safeadd(
                currentbalancesum,
                safemul(prebalance, now  lastmodified)
            );
        }

        return issuancedata(currentbalancesum, lastaveragebalance, now);
    }

    
    function recomputelastaveragebalance(address account)
        external
        returns (uint)
    {
        updateissuancedata(account, nominsissued[account], nomin.totalsupply());
        return issuancedata[account].lastaveragebalance;
    }

    
    function issuenomins(uint amount)
        public
        optionalproxy
        requireissuer(messagesender)
        
    {
        address sender = messagesender;
        require(amount <= remainingissuablenomins(sender), );
        uint lasttot = nomin.totalsupply();
        uint preissued = nominsissued[sender];
        nomin.issue(sender, amount);
        nominsissued[sender] = safeadd(preissued, amount);
        updateissuancedata(sender, preissued, lasttot);
    }

    function issuemaxnomins()
        external
        optionalproxy
    {
        issuenomins(remainingissuablenomins(messagesender));
    }

    
    function burnnomins(uint amount)
        
        external
        optionalproxy
    {
        address sender = messagesender;

        uint lasttot = nomin.totalsupply();
        uint preissued = nominsissued[sender];
        
        nomin.burn(sender, amount);
        
        nominsissued[sender] = safesub(preissued, amount);
        updateissuancedata(sender, preissued, lasttot);
    }

    
    function rolloverfeeperiodifelapsed()
        public
    {
        
        if (now >= feeperiodstarttime + feeperiodduration) {
            lastfeescollected = nomin.feepool();
            lastfeeperiodstarttime = feeperiodstarttime;
            feeperiodstarttime = now;
            emitfeeperiodrollover(now);
        }
    }

    

    
    function maxissuablenomins(address issuer)
        view
        public
        pricenotstale
        returns (uint)
    {
        if (!isissuer[issuer]) {
            return 0;
        }
        if (escrow != havvenescrow(0)) {
            uint totalownedhavvens = safeadd(tokenstate.balanceof(issuer), escrow.balanceof(issuer));
            return safemul_dec(havtousd(totalownedhavvens), issuanceratio);
        } else {
            return safemul_dec(havtousd(tokenstate.balanceof(issuer)), issuanceratio);
        }
    }

    
    function remainingissuablenomins(address issuer)
        view
        public
        returns (uint)
    {
        uint issued = nominsissued[issuer];
        uint max = maxissuablenomins(issuer);
        if (issued > max) {
            return 0;
        } else {
            return safesub(max, issued);
        }
    }

    
    function collateral(address account)
        public
        view
        returns (uint)
    {
        uint bal = tokenstate.balanceof(account);
        if (escrow != address(0)) {
            bal = safeadd(bal, escrow.balanceof(account));
        }
        return bal;
    }

    
    function issuancedraft(address account)
        public
        view
        returns (uint)
    {
        uint issued = nominsissued[account];
        if (issued == 0) {
            return 0;
        }
        return usdtohav(safediv_dec(issued, issuanceratio));
    }

    
    function lockedcollateral(address account)
        public
        view
        returns (uint)
    {
        uint debt = issuancedraft(account);
        uint collat = collateral(account);
        if (debt > collat) {
            return collat;
        }
        return debt;
    }

    
    function unlockedcollateral(address account)
        public
        view
        returns (uint)
    {
        uint locked = lockedcollateral(account);
        uint collat = collateral(account);
        return safesub(collat, locked);
    }

    
    function transferablehavvens(address account)
        public
        view
        returns (uint)
    {
        uint draft = issuancedraft(account);
        uint collat = collateral(account);
        
        if (draft > collat) {
            return 0;
        }

        uint bal = balanceof(account);
        
        
        if (draft > safesub(collat, bal)) {
            return safesub(collat, draft);
        }
        
        return bal;
    }

    
    function havtousd(uint hav_dec)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safemul_dec(hav_dec, price);
    }

    
    function usdtohav(uint usd_dec)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safediv_dec(usd_dec, price);
    }

    
    function updateprice(uint newprice, uint timesent)
        external
        onlyoracle  
    {
        
        require(lastpriceupdatetime < timesent && timesent < now + oracle_future_limit,
            );

        price = newprice;
        lastpriceupdatetime = timesent;
        emitpriceupdated(newprice, timesent);

        
        rolloverfeeperiodifelapsed();
    }

    
    function priceisstale()
        public
        view
        returns (bool)
    {
        return safeadd(lastpriceupdatetime, pricestaleperiod) < now;
    }

    

    modifier requireissuer(address account)
    {
        require(isissuer[account], );
        _;
    }

    modifier onlyoracle
    {
        require(msg.sender == oracle, );
        _;
    }

    modifier pricenotstale
    {
        require(!priceisstale(), );
        _;
    }

    

    event priceupdated(uint newprice, uint timestamp);
    bytes32 constant priceupdated_sig = keccak256();
    function emitpriceupdated(uint newprice, uint timestamp) internal {
        proxy._emit(abi.encode(newprice, timestamp), 1, priceupdated_sig, 0, 0, 0);
    }

    event issuanceratioupdated(uint newratio);
    bytes32 constant issuanceratioupdated_sig = keccak256();
    function emitissuanceratioupdated(uint newratio) internal {
        proxy._emit(abi.encode(newratio), 1, issuanceratioupdated_sig, 0, 0, 0);
    }

    event feeperiodrollover(uint timestamp);
    bytes32 constant feeperiodrollover_sig = keccak256();
    function emitfeeperiodrollover(uint timestamp) internal {
        proxy._emit(abi.encode(timestamp), 1, feeperiodrollover_sig, 0, 0, 0);
    } 

    event feeperioddurationupdated(uint duration);
    bytes32 constant feeperioddurationupdated_sig = keccak256();
    function emitfeeperioddurationupdated(uint duration) internal {
        proxy._emit(abi.encode(duration), 1, feeperioddurationupdated_sig, 0, 0, 0);
    } 

    event feeswithdrawn(address indexed account, uint value);
    bytes32 constant feeswithdrawn_sig = keccak256();
    function emitfeeswithdrawn(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, feeswithdrawn_sig, bytes32(account), 0, 0);
    }

    event oracleupdated(address neworacle);
    bytes32 constant oracleupdated_sig = keccak256();
    function emitoracleupdated(address neworacle) internal {
        proxy._emit(abi.encode(neworacle), 1, oracleupdated_sig, 0, 0, 0);
    }

    event nominupdated(address newnomin);
    bytes32 constant nominupdated_sig = keccak256();
    function emitnominupdated(address newnomin) internal {
        proxy._emit(abi.encode(newnomin), 1, nominupdated_sig, 0, 0, 0);
    }

    event escrowupdated(address newescrow);
    bytes32 constant escrowupdated_sig = keccak256();
    function emitescrowupdated(address newescrow) internal {
        proxy._emit(abi.encode(newescrow), 1, escrowupdated_sig, 0, 0, 0);
    }

    event issuersupdated(address indexed account, bool indexed value);
    bytes32 constant issuersupdated_sig = keccak256();
    function emitissuersupdated(address account, bool value) internal {
        proxy._emit(abi.encode(), 3, issuersupdated_sig, bytes32(account), bytes32(value ? 1 : 0), 0);
    }

}
