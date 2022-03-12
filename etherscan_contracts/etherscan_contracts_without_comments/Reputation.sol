

pragma solidity 0.4.20;



contract ityped {
    function gettypename() public view returns (bytes32);
}




contract erc20basic {
    event transfer(address indexed from, address indexed to, uint256 value);

    function balanceof(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function totalsupply() public view returns (uint256);
}




contract erc20 is erc20basic {
    event approval(address indexed owner, address indexed spender, uint256 value);

    function allowance(address _owner, address _spender) public view returns (uint256);
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
}



contract ireputationtoken is ityped, erc20 {
    function initialize(iuniverse _universe) public returns (bool);
    function migrateout(ireputationtoken _destination, uint256 _attotokens) public returns (bool);
    function migratein(address _reporter, uint256 _attotokens) public returns (bool);
    function trustedreportingparticipanttransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedmarkettransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedfeewindowtransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trusteduniversetransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function getuniverse() public view returns (iuniverse);
    function gettotalmigrated() public view returns (uint256);
    function gettotaltheoreticalsupply() public view returns (uint256);
    function mintforreportingparticipant(uint256 _amountmigrated) public returns (bool);
}



contract iownable {
    function getowner() public view returns (address);
    function transferownership(address newowner) public returns (bool);
}



contract icash is erc20 {
    function depositether() external payable returns(bool);
    function depositetherfor(address _to) external payable returns(bool);
    function withdrawether(uint256 _amount) external returns(bool);
    function withdrawetherto(address _to, uint256 _amount) external returns(bool);
    function withdrawethertoifpossible(address _to, uint256 _amount) external returns (bool);
}



contract isharetoken is ityped, erc20 {
    function initialize(imarket _market, uint256 _outcome) external returns (bool);
    function createshares(address _owner, uint256 _amount) external returns (bool);
    function destroyshares(address, uint256 balance) external returns (bool);
    function getmarket() external view returns (imarket);
    function getoutcome() external view returns (uint256);
    function trustedordertransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedfillordertransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedcancelordertransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
}



contract ireportingparticipant {
    function getstake() public view returns (uint256);
    function getpayoutdistributionhash() public view returns (bytes32);
    function liquidatelosing() public returns (bool);
    function redeem(address _redeemer) public returns (bool);
    function isinvalid() public view returns (bool);
    function isdisavowed() public view returns (bool);
    function migrate() public returns (bool);
    function getpayoutnumerator(uint256 _outcome) public view returns (uint256);
    function getmarket() public view returns (imarket);
    function getsize() public view returns (uint256);
}



contract imailbox {
    function initialize(address _owner, imarket _market) public returns (bool);
    function depositether() public payable returns (bool);
}







contract imarket is ityped, iownable {
    enum markettype {
        yes_no,
        categorical,
        scalar
    }

    function initialize(iuniverse _universe, uint256 _endtime, uint256 _feeperethinattoeth, icash _cash, address _designatedreporteraddress, address _creator, uint256 _numoutcomes, uint256 _numticks) public payable returns (bool _success);
    function derivepayoutdistributionhash(uint256[] _payoutnumerators, bool _invalid) public view returns (bytes32);
    function getuniverse() public view returns (iuniverse);
    function getfeewindow() public view returns (ifeewindow);
    function getnumberofoutcomes() public view returns (uint256);
    function getnumticks() public view returns (uint256);
    function getdenominationtoken() public view returns (icash);
    function getsharetoken(uint256 _outcome)  public view returns (isharetoken);
    function getmarketcreatorsettlementfeedivisor() public view returns (uint256);
    function getforkingmarket() public view returns (imarket _market);
    function getendtime() public view returns (uint256);
    function getmarketcreatormailbox() public view returns (imailbox);
    function getwinningpayoutdistributionhash() public view returns (bytes32);
    function getwinningpayoutnumerator(uint256 _outcome) public view returns (uint256);
    function getreputationtoken() public view returns (ireputationtoken);
    function getfinalizationtime() public view returns (uint256);
    function getinitialreporteraddress() public view returns (address);
    function derivemarketcreatorfeeamount(uint256 _amount) public view returns (uint256);
    function iscontainerforsharetoken(isharetoken _shadytarget) public view returns (bool);
    function iscontainerforreportingparticipant(ireportingparticipant _reportingparticipant) public view returns (bool);
    function isinvalid() public view returns (bool);
    function finalize() public returns (bool);
    function designatedreporterwascorrect() public view returns (bool);
    function designatedreportershowed() public view returns (bool);
    function isfinalized() public view returns (bool);
    function finalizefork() public returns (bool);
    function assertbalances() public view returns (bool);
}



contract initializable {
    bool private initialized = false;

    modifier afterinitialized {
        require(initialized);
        _;
    }

    modifier beforeinitialized {
        require(!initialized);
        _;
    }

    function endinitialization() internal beforeinitialized returns (bool) {
        initialized = true;
        return true;
    }

    function getinitialized() public view returns (bool) {
        return initialized;
    }
}



contract ifeetoken is erc20, initializable {
    function initialize(ifeewindow _feewindow) public returns (bool);
    function getfeewindow() public view returns (ifeewindow);
    function feewindowburn(address _target, uint256 _amount) public returns (bool);
    function mintforreportingparticipant(address _target, uint256 _amount) public returns (bool);
}



contract ifeewindow is ityped, erc20 {
    function initialize(iuniverse _universe, uint256 _feewindowid) public returns (bool);
    function getuniverse() public view returns (iuniverse);
    function getreputationtoken() public view returns (ireputationtoken);
    function getstarttime() public view returns (uint256);
    function getendtime() public view returns (uint256);
    function getnummarkets() public view returns (uint256);
    function getnuminvalidmarkets() public view returns (uint256);
    function getnumincorrectdesignatedreportmarkets() public view returns (uint256);
    function getnumdesignatedreportnoshows() public view returns (uint256);
    function getfeetoken() public view returns (ifeetoken);
    function isactive() public view returns (bool);
    function isover() public view returns (bool);
    function onmarketfinalized() public returns (bool);
    function buy(uint256 _attotokens) public returns (bool);
    function redeem(address _sender) public returns (bool);
    function redeemforreportingparticipant() public returns (bool);
    function mintfeetokens(uint256 _amount) public returns (bool);
    function trusteduniversebuy(address _buyer, uint256 _attotokens) public returns (bool);
}



contract iuniverse is ityped {
    function initialize(iuniverse _parentuniverse, bytes32 _parentpayoutdistributionhash) external returns (bool);
    function fork() public returns (bool);
    function getparentuniverse() public view returns (iuniverse);
    function createchilduniverse(uint256[] _parentpayoutnumerators, bool _invalid) public returns (iuniverse);
    function getchilduniverse(bytes32 _parentpayoutdistributionhash) public view returns (iuniverse);
    function getreputationtoken() public view returns (ireputationtoken);
    function getforkingmarket() public view returns (imarket);
    function getforkendtime() public view returns (uint256);
    function getforkreputationgoal() public view returns (uint256);
    function getparentpayoutdistributionhash() public view returns (bytes32);
    function getdisputerounddurationinseconds() public view returns (uint256);
    function getorcreatefeewindowbytimestamp(uint256 _timestamp) public returns (ifeewindow);
    function getorcreatecurrentfeewindow() public returns (ifeewindow);
    function getorcreatenextfeewindow() public returns (ifeewindow);
    function getopeninterestinattoeth() public view returns (uint256);
    function getrepmarketcapinattoeth() public view returns (uint256);
    function gettargetrepmarketcapinattoeth() public view returns (uint256);
    function getorcachevaliditybond() public returns (uint256);
    function getorcachedesignatedreportstake() public returns (uint256);
    function getorcachedesignatedreportnoshowbond() public returns (uint256);
    function getorcachereportingfeedivisor() public returns (uint256);
    function getdisputethresholdforfork() public view returns (uint256);
    function getinitialreportminvalue() public view returns (uint256);
    function calculatefloatingvalue(uint256 _badmarkets, uint256 _totalmarkets, uint256 _targetdivisor, uint256 _previousvalue, uint256 _defaultvalue, uint256 _floor) public pure returns (uint256 _newvalue);
    function getorcachemarketcreationcost() public returns (uint256);
    function getcurrentfeewindow() public view returns (ifeewindow);
    function getorcreatefeewindowbefore(ifeewindow _feewindow) public returns (ifeewindow);
    function isparentof(iuniverse _shadychild) public view returns (bool);
    function updatetentativewinningchilduniverse(bytes32 _parentpayoutdistributionhash) public returns (bool);
    function iscontainerforfeewindow(ifeewindow _shadytarget) public view returns (bool);
    function iscontainerformarket(imarket _shadytarget) public view returns (bool);
    function iscontainerforreportingparticipant(ireportingparticipant _reportingparticipant) public view returns (bool);
    function iscontainerforsharetoken(isharetoken _shadytarget) public view returns (bool);
    function iscontainerforfeetoken(ifeetoken _shadytarget) public view returns (bool);
    function addmarketto() public returns (bool);
    function removemarketfrom() public returns (bool);
    function decrementopeninterest(uint256 _amount) public returns (bool);
    function decrementopeninterestfrommarket(uint256 _amount) public returns (bool);
    function incrementopeninterest(uint256 _amount) public returns (bool);
    function incrementopeninterestfrommarket(uint256 _amount) public returns (bool);
    function getwinningchilduniverse() public view returns (iuniverse);
    function isforking() public view returns (bool);
}



contract idisputecrowdsourcer is ireportingparticipant, erc20 {
    function initialize(imarket market, uint256 _size, bytes32 _payoutdistributionhash, uint256[] _payoutnumerators, bool _invalid) public returns (bool);
    function contribute(address _participant, uint256 _amount) public returns (uint256);
}




library safemathuint256 {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a  b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }

    function getuint256min() internal pure returns (uint256) {
        return 0;
    }

    function getuint256max() internal pure returns (uint256) {
        return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    function ismultipleof(uint256 a, uint256 b) internal pure returns (bool) {
        return a % b == 0;
    }

    
    function fxpmul(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {
        return div(mul(a, b), base);
    }

    function fxpdiv(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {
        return div(mul(a, base), b);
    }
}



contract iorders {
    function saveorder(order.types _type, imarket _market, uint256 _fxpamount, uint256 _price, address _sender, uint256 _outcome, uint256 _moneyescrowed, uint256 _sharesescrowed, bytes32 _betterorderid, bytes32 _worseorderid, bytes32 _tradegroupid) public returns (bytes32 _orderid);
    function removeorder(bytes32 _orderid) public returns (bool);
    function getmarket(bytes32 _orderid) public view returns (imarket);
    function getordertype(bytes32 _orderid) public view returns (order.types);
    function getoutcome(bytes32 _orderid) public view returns (uint256);
    function getamount(bytes32 _orderid) public view returns (uint256);
    function getprice(bytes32 _orderid) public view returns (uint256);
    function getordercreator(bytes32 _orderid) public view returns (address);
    function getordersharesescrowed(bytes32 _orderid) public view returns (uint256);
    function getordermoneyescrowed(bytes32 _orderid) public view returns (uint256);
    function getbetterorderid(bytes32 _orderid) public view returns (bytes32);
    function getworseorderid(bytes32 _orderid) public view returns (bytes32);
    function getbestorderid(order.types _type, imarket _market, uint256 _outcome) public view returns (bytes32);
    function getworstorderid(order.types _type, imarket _market, uint256 _outcome) public view returns (bytes32);
    function getlastoutcomeprice(imarket _market, uint256 _outcome) public view returns (uint256);
    function getorderid(order.types _type, imarket _market, uint256 _fxpamount, uint256 _price, address _sender, uint256 _blocknumber, uint256 _outcome, uint256 _moneyescrowed, uint256 _sharesescrowed) public pure returns (bytes32);
    function gettotalescrowed(imarket _market) public view returns (uint256);
    function isbetterprice(order.types _type, uint256 _price, bytes32 _orderid) public view returns (bool);
    function isworseprice(order.types _type, uint256 _price, bytes32 _orderid) public view returns (bool);
    function assertisnotbetterprice(order.types _type, uint256 _price, bytes32 _betterorderid) public view returns (bool);
    function assertisnotworseprice(order.types _type, uint256 _price, bytes32 _worseorderid) public returns (bool);
    function recordfillorder(bytes32 _orderid, uint256 _sharesfilled, uint256 _tokensfilled) public returns (bool);
    function setprice(imarket _market, uint256 _outcome, uint256 _price) external returns (bool);
    function incrementtotalescrowed(imarket _market, uint256 _amount) external returns (bool);
    function decrementtotalescrowed(imarket _market, uint256 _amount) external returns (bool);
}










pragma solidity 0.4.20;








library order {
    using safemathuint256 for uint256;

    enum types {
        bid, ask
    }

    enum tradedirections {
        long, short
    }

    struct data {
        
        iorders orders;
        imarket market;
        iaugur augur;

        
        bytes32 id;
        address creator;
        uint256 outcome;
        order.types ordertype;
        uint256 amount;
        uint256 price;
        uint256 sharesescrowed;
        uint256 moneyescrowed;
        bytes32 betterorderid;
        bytes32 worseorderid;
    }

    
    
    
    function create(icontroller _controller, address _creator, uint256 _outcome, order.types _type, uint256 _attoshares, uint256 _price, imarket _market, bytes32 _betterorderid, bytes32 _worseorderid) internal view returns (data) {
        require(_outcome < _market.getnumberofoutcomes());
        require(_price < _market.getnumticks());

        iorders _orders = iorders(_controller.lookup());
        iaugur _augur = _controller.getaugur();

        return data({
            orders: _orders,
            market: _market,
            augur: _augur,
            id: 0,
            creator: _creator,
            outcome: _outcome,
            ordertype: _type,
            amount: _attoshares,
            price: _price,
            sharesescrowed: 0,
            moneyescrowed: 0,
            betterorderid: _betterorderid,
            worseorderid: _worseorderid
        });
    }

    
    
    function getorderid(order.data _orderdata) internal view returns (bytes32) {
        if (_orderdata.id == bytes32(0)) {
            bytes32 _orderid = _orderdata.orders.getorderid(_orderdata.ordertype, _orderdata.market, _orderdata.amount, _orderdata.price, _orderdata.creator, block.number, _orderdata.outcome, _orderdata.moneyescrowed, _orderdata.sharesescrowed);
            require(_orderdata.orders.getamount(_orderid) == 0);
            _orderdata.id = _orderid;
        }
        return _orderdata.id;
    }

    function getordertradingtypefrommakerdirection(order.tradedirections _creatordirection) internal pure returns (order.types) {
        return (_creatordirection == order.tradedirections.long) ? order.types.bid : order.types.ask;
    }

    function getordertradingtypefromfillerdirection(order.tradedirections _fillerdirection) internal pure returns (order.types) {
        return (_fillerdirection == order.tradedirections.long) ? order.types.ask : order.types.bid;
    }

    function escrowfunds(order.data _orderdata) internal returns (bool) {
        if (_orderdata.ordertype == order.types.ask) {
            return escrowfundsforask(_orderdata);
        } else if (_orderdata.ordertype == order.types.bid) {
            return escrowfundsforbid(_orderdata);
        }
    }

    function saveorder(order.data _orderdata, bytes32 _tradegroupid) internal returns (bytes32) {
        return _orderdata.orders.saveorder(_orderdata.ordertype, _orderdata.market, _orderdata.amount, _orderdata.price, _orderdata.creator, _orderdata.outcome, _orderdata.moneyescrowed, _orderdata.sharesescrowed, _orderdata.betterorderid, _orderdata.worseorderid, _tradegroupid);
    }

    
    
    function escrowfundsforbid(order.data _orderdata) private returns (bool) {
        require(_orderdata.moneyescrowed == 0);
        require(_orderdata.sharesescrowed == 0);
        uint256 _attosharestocover = _orderdata.amount;
        uint256 _numberofoutcomes = _orderdata.market.getnumberofoutcomes();

        
        uint256 _attosharesheld = 2**254;
        for (uint256 _i = 0; _i < _numberofoutcomes; _i++) {
            if (_i != _orderdata.outcome) {
                uint256 _creatorsharetokenbalance = _orderdata.market.getsharetoken(_i).balanceof(_orderdata.creator);
                _attosharesheld = safemathuint256.min(_creatorsharetokenbalance, _attosharesheld);
            }
        }

        
        if (_attosharesheld > 0) {
            _orderdata.sharesescrowed = safemathuint256.min(_attosharesheld, _attosharestocover);
            _attosharestocover = _orderdata.sharesescrowed;
            for (_i = 0; _i < _numberofoutcomes; _i++) {
                if (_i != _orderdata.outcome) {
                    _orderdata.market.getsharetoken(_i).trustedordertransfer(_orderdata.creator, _orderdata.market, _orderdata.sharesescrowed);
                }
            }
        }
        
        if (_attosharestocover > 0) {
            _orderdata.moneyescrowed = _attosharestocover.mul(_orderdata.price);
            require(_orderdata.augur.trustedtransfer(_orderdata.market.getdenominationtoken(), _orderdata.creator, _orderdata.market, _orderdata.moneyescrowed));
        }

        return true;
    }

    function escrowfundsforask(order.data _orderdata) private returns (bool) {
        require(_orderdata.moneyescrowed == 0);
        require(_orderdata.sharesescrowed == 0);
        isharetoken _sharetoken = _orderdata.market.getsharetoken(_orderdata.outcome);
        uint256 _attosharestocover = _orderdata.amount;

        
        uint256 _attosharesheld = _sharetoken.balanceof(_orderdata.creator);

        
        if (_attosharesheld > 0) {
            _orderdata.sharesescrowed = safemathuint256.min(_attosharesheld, _attosharestocover);
            _attosharestocover = _orderdata.sharesescrowed;
            _sharetoken.trustedordertransfer(_orderdata.creator, _orderdata.market, _orderdata.sharesescrowed);
        }

        
        if (_attosharestocover > 0) {
            _orderdata.moneyescrowed = _orderdata.market.getnumticks().sub(_orderdata.price).mul(_attosharestocover);
            require(_orderdata.augur.trustedtransfer(_orderdata.market.getdenominationtoken(), _orderdata.creator, _orderdata.market, _orderdata.moneyescrowed));
        }

        return true;
    }
}



contract iaugur {
    function createchilduniverse(bytes32 _parentpayoutdistributionhash, uint256[] _parentpayoutnumerators, bool _parentinvalid) public returns (iuniverse);
    function isknownuniverse(iuniverse _universe) public view returns (bool);
    function trustedtransfer(erc20 _token, address _from, address _to, uint256 _amount) public returns (bool);
    function logmarketcreated(bytes32 _topic, string _description, string _extrainfo, iuniverse _universe, address _market, address _marketcreator, bytes32[] _outcomes, int256 _minprice, int256 _maxprice, imarket.markettype _markettype) public returns (bool);
    function logmarketcreated(bytes32 _topic, string _description, string _extrainfo, iuniverse _universe, address _market, address _marketcreator, int256 _minprice, int256 _maxprice, imarket.markettype _markettype) public returns (bool);
    function loginitialreportsubmitted(iuniverse _universe, address _reporter, address _market, uint256 _amountstaked, bool _isdesignatedreporter, uint256[] _payoutnumerators, bool _invalid) public returns (bool);
    function disputecrowdsourcercreated(iuniverse _universe, address _market, address _disputecrowdsourcer, uint256[] _payoutnumerators, uint256 _size, bool _invalid) public returns (bool);
    function logdisputecrowdsourcercontribution(iuniverse _universe, address _reporter, address _market, address _disputecrowdsourcer, uint256 _amountstaked) public returns (bool);
    function logdisputecrowdsourcercompleted(iuniverse _universe, address _market, address _disputecrowdsourcer) public returns (bool);
    function loginitialreporterredeemed(iuniverse _universe, address _reporter, address _market, uint256 _amountredeemed, uint256 _repreceived, uint256 _reportingfeesreceived, uint256[] _payoutnumerators) public returns (bool);
    function logdisputecrowdsourcerredeemed(iuniverse _universe, address _reporter, address _market, uint256 _amountredeemed, uint256 _repreceived, uint256 _reportingfeesreceived, uint256[] _payoutnumerators) public returns (bool);
    function logfeewindowredeemed(iuniverse _universe, address _reporter, uint256 _amountredeemed, uint256 _reportingfeesreceived) public returns (bool);
    function logmarketfinalized(iuniverse _universe) public returns (bool);
    function logmarketmigrated(imarket _market, iuniverse _originaluniverse) public returns (bool);
    function logreportingparticipantdisavowed(iuniverse _universe, imarket _market) public returns (bool);
    function logmarketparticipantsdisavowed(iuniverse _universe) public returns (bool);
    function logordercanceled(iuniverse _universe, address _sharetoken, address _sender, bytes32 _orderid, order.types _ordertype, uint256 _tokenrefund, uint256 _sharesrefund) public returns (bool);
    function logordercreated(order.types _ordertype, uint256 _amount, uint256 _price, address _creator, uint256 _moneyescrowed, uint256 _sharesescrowed, bytes32 _tradegroupid, bytes32 _orderid, iuniverse _universe, address _sharetoken) public returns (bool);
    function logorderfilled(iuniverse _universe, address _sharetoken, address _filler, bytes32 _orderid, uint256 _numcreatorshares, uint256 _numcreatortokens, uint256 _numfillershares, uint256 _numfillertokens, uint256 _marketcreatorfees, uint256 _reporterfees, uint256 _amountfilled, bytes32 _tradegroupid) public returns (bool);
    function logcompletesetspurchased(iuniverse _universe, imarket _market, address _account, uint256 _numcompletesets) public returns (bool);
    function logcompletesetssold(iuniverse _universe, imarket _market, address _account, uint256 _numcompletesets) public returns (bool);
    function logtradingproceedsclaimed(iuniverse _universe, address _sharetoken, address _sender, address _market, uint256 _numshares, uint256 _numpayouttokens, uint256 _finaltokenbalance) public returns (bool);
    function loguniverseforked() public returns (bool);
    function logfeewindowtransferred(iuniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
    function logreputationtokenstransferred(iuniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
    function logdisputecrowdsourcertokenstransferred(iuniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
    function logsharetokenstransferred(iuniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
    function logreputationtokenburned(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logreputationtokenminted(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logsharetokenburned(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logsharetokenminted(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logfeewindowburned(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logfeewindowminted(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logdisputecrowdsourcertokensburned(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logdisputecrowdsourcertokensminted(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logfeewindowcreated(ifeewindow _feewindow, uint256 _id) public returns (bool);
    function logfeetokentransferred(iuniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
    function logfeetokenburned(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logfeetokenminted(iuniverse _universe, address _target, uint256 _amount) public returns (bool);
    function logtimestampset(uint256 _newtimestamp) public returns (bool);
    function loginitialreportertransferred(iuniverse _universe, imarket _market, address _from, address _to) public returns (bool);
    function logmarkettransferred(iuniverse _universe, address _from, address _to) public returns (bool);
    function logmarketmailboxtransferred(iuniverse _universe, imarket _market, address _from, address _to) public returns (bool);
    function logescapehatchchanged(bool _ison) public returns (bool);
}



contract icontroller {
    function assertiswhitelisted(address _target) public view returns(bool);
    function lookup(bytes32 _key) public view returns(address);
    function stopinemergency() public view returns(bool);
    function onlyinemergency() public view returns(bool);
    function getaugur() public view returns (iaugur);
    function gettimestamp() public view returns (uint256);
}



contract icontrolled {
    function getcontroller() public view returns (icontroller);
    function setcontroller(icontroller _controller) public returns(bool);
}



contract controlled is icontrolled {
    icontroller internal controller;

    modifier onlywhitelistedcallers {
        require(controller.assertiswhitelisted(msg.sender));
        _;
    }

    modifier onlycaller(bytes32 _key) {
        require(msg.sender == controller.lookup(_key));
        _;
    }

    modifier onlycontrollercaller {
        require(icontroller(msg.sender) == controller);
        _;
    }

    modifier onlyingoodtimes {
        require(controller.stopinemergency());
        _;
    }

    modifier onlyinbadtimes {
        require(controller.onlyinemergency());
        _;
    }

    function controlled() public {
        controller = icontroller(msg.sender);
    }

    function getcontroller() public view returns(icontroller) {
        return controller;
    }

    function setcontroller(icontroller _controller) public onlycontrollercaller returns(bool) {
        controller = _controller;
        return true;
    }
}



contract delegationtarget is controlled {
    bytes32 public controllerlookupname;
}



contract delegator is delegationtarget {
    function delegator(icontroller _controller, bytes32 _controllerlookupname) public {
        controller = _controller;
        controllerlookupname = _controllerlookupname;
    }

    function() external payable {
        
        if (controllerlookupname == 0) {
            return;
        }

        
        address _target = controller.lookup(controllerlookupname);

        assembly {
            
            let _calldatamemoryoffset := mload(0x40)
            
            let _size := and(add(calldatasize, 0x1f), not(0x1f))
            
            mstore(0x40, add(_calldatamemoryoffset, _size))
            
            calldatacopy(_calldatamemoryoffset, 0x0, calldatasize)
            
            let _retval := delegatecall(gas, _target, _calldatamemoryoffset, calldatasize, 0, 0)
            switch _retval
            case 0 {
                
                revert(0,0)
            } default {
                
                let _returndatamemoryoffset := mload(0x40)
                
                mstore(0x40, add(_returndatamemoryoffset, returndatasize))
                returndatacopy(_returndatamemoryoffset, 0x0, returndatasize)
                return(_returndatamemoryoffset, returndatasize)
            }
        }
    }
}