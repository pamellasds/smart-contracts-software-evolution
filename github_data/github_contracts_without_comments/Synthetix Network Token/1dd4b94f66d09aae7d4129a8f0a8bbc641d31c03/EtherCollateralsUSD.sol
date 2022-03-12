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




contract ethercollateralsusd is owned, pausable, reentrancyguard, mixinresolver, iethercollateralsusd {
    using safemath for uint256;
    using safedecimalmath for uint256;

    bytes32 internal constant eth = ;

    
    uint256 internal constant one_thousand = 1e18 * 1000;
    uint256 internal constant one_hundred = 1e18 * 100;

    uint256 internal constant seconds_in_a_year = 31536000; 

    
    address internal constant fee_address = 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef;

    uint256 internal constant account_loan_limit_cap = 1000;
    bytes32 private constant susd = ;
    bytes32 public constant collateral = ;

    

    
    uint256 public collateralizationratio = safedecimalmath.unit() * 150;

    
    uint256 public interestrate = (5 * safedecimalmath.unit()) / 100;
    uint256 public interestpersecond = interestrate.div(seconds_in_a_year);

    
    uint256 public issuefeerate = (5 * safedecimalmath.unit()) / 1000;

    
    uint256 public issuelimit = safedecimalmath.unit() * 10000000;

    
    uint256 public minloancollateralsize = safedecimalmath.unit() * 1;

    
    uint256 public accountloanlimit = 50;

    
    bool public loanliquidationopen = false;

    
    uint256 public liquidationdeadline;

    
    uint256 public liquidationratio = (150 * safedecimalmath.unit()) / 100; 

    
    uint256 public liquidationpenalty = safedecimalmath.unit() / 10;

    

    
    uint256 public totalissuedsynths;

    
    uint256 public totalloanscreated;

    
    uint256 public totalopenloancount;

    
    struct synthloanstruct {
        
        address payable account;
        
        uint256 collateralamount;
        
        uint256 loanamount;
        
        uint256 mintingfee;
        
        uint256 timecreated;
        
        uint256 loanid;
        
        uint256 timeclosed;
        
        uint256 loaninterestrate;
        
        uint256 accruedinterest;
        
        uint40 lastinterestaccrued;
    }

    
    mapping(address => synthloanstruct[]) public accountssynthloans;

    
    mapping(address => uint256) public accountopenloancounter;

    

    bytes32 private constant contract_systemstatus = ;
    bytes32 private constant contract_synthsusd = ;
    bytes32 private constant contract_exrates = ;
    bytes32 private constant contract_feepool = ;

    bytes32[24] private addressestocache = [contract_systemstatus, contract_synthsusd, contract_exrates, contract_feepool];

    
    constructor(address _owner, address _resolver)
        public
        owned(_owner)
        pausable()
        mixinresolver(_resolver, addressestocache)
    {
        liquidationdeadline = block.timestamp + 92 days; 
    }

    

    function setcollateralizationratio(uint256 ratio) external onlyowner {
        require(ratio <= one_thousand, );
        require(ratio >= one_hundred, );
        collateralizationratio = ratio;
        emit collateralizationratioupdated(ratio);
    }

    function setinterestrate(uint256 _interestrate) external onlyowner {
        require(_interestrate > seconds_in_a_year, );
        require(_interestrate <= safedecimalmath.unit(), );
        interestrate = _interestrate;
        interestpersecond = _interestrate.div(seconds_in_a_year);
        emit interestrateupdated(interestrate);
    }

    function setissuefeerate(uint256 _issuefeerate) external onlyowner {
        issuefeerate = _issuefeerate;
        emit issuefeerateupdated(issuefeerate);
    }

    function setissuelimit(uint256 _issuelimit) external onlyowner {
        issuelimit = _issuelimit;
        emit issuelimitupdated(issuelimit);
    }

    function setminloancollateralsize(uint256 _minloancollateralsize) external onlyowner {
        minloancollateralsize = _minloancollateralsize;
        emit minloancollateralsizeupdated(minloancollateralsize);
    }

    function setaccountloanlimit(uint256 _loanlimit) external onlyowner {
        require(_loanlimit < account_loan_limit_cap, );
        accountloanlimit = _loanlimit;
        emit accountloanlimitupdated(accountloanlimit);
    }

    function setloanliquidationopen(bool _loanliquidationopen) external onlyowner {
        require(block.timestamp > liquidationdeadline, );
        loanliquidationopen = _loanliquidationopen;
        emit loanliquidationopenupdated(loanliquidationopen);
    }

    function setliquidationratio(uint256 _liquidationratio) external onlyowner {
        require(_liquidationratio > safedecimalmath.unit(), );
        liquidationratio = _liquidationratio;
        emit liquidationratioupdated(liquidationratio);
    }

    

    function getcontractinfo()
        external
        view
        returns (
            uint256 _collateralizationratio,
            uint256 _issuanceratio,
            uint256 _interestrate,
            uint256 _interestpersecond,
            uint256 _issuefeerate,
            uint256 _issuelimit,
            uint256 _minloancollateralsize,
            uint256 _totalissuedsynths,
            uint256 _totalloanscreated,
            uint256 _totalopenloancount,
            uint256 _ethbalance,
            uint256 _liquidationdeadline,
            bool _loanliquidationopen
        )
    {
        _collateralizationratio = collateralizationratio;
        _issuanceratio = issuanceratio();
        _interestrate = interestrate;
        _interestpersecond = interestpersecond;
        _issuefeerate = issuefeerate;
        _issuelimit = issuelimit;
        _minloancollateralsize = minloancollateralsize;
        _totalissuedsynths = totalissuedsynths;
        _totalloanscreated = totalloanscreated;
        _totalopenloancount = totalopenloancount;
        _ethbalance = address(this).balance;
        _liquidationdeadline = liquidationdeadline;
        _loanliquidationopen = loanliquidationopen;
    }

    
    
    function issuanceratio() public view returns (uint256) {
        
        return one_hundred.dividedecimalround(collateralizationratio);
    }

    function loanamountfromcollateral(uint256 collateralamount) public view returns (uint256) {
        
        return collateralamount.multiplydecimal(issuanceratio()).multiplydecimal(exchangerates().rateforcurrency(eth));
    }

    function collateralamountforloan(uint256 loanamount) external view returns (uint256) {
        return
            loanamount
                .multiplydecimal(collateralizationratio.dividedecimalround(exchangerates().rateforcurrency(eth)))
                .dividedecimalround(one_hundred);
    }

    
    function currentinterestonloan(address _account, uint256 _loanid) external view returns (uint256) {
        
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);
        uint256 currentinterest = accruedinterestonloan(
            synthloan.loanamount.add(synthloan.accruedinterest),
            _timesinceinterestaccrual(synthloan)
        );
        return synthloan.accruedinterest.add(currentinterest);
    }

    function accruedinterestonloan(uint256 _loanamount, uint256 _seconds) public view returns (uint256 interestamount) {
        
        
        interestamount = _loanamount.multiplydecimalround(interestpersecond.mul(_seconds));
    }

    function totalfeesonloan(address _account, uint256 _loanid)
        external
        view
        returns (uint256 interestamount, uint256 mintingfee)
    {
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);
        uint256 loanamountwithaccruedinterest = synthloan.loanamount.add(synthloan.accruedinterest);
        interestamount = synthloan.accruedinterest.add(
            accruedinterestonloan(loanamountwithaccruedinterest, _timesinceinterestaccrual(synthloan))
        );
        mintingfee = synthloan.mintingfee;
    }

    function getmintingfee(address _account, uint256 _loanid) external view returns (uint256) {
        
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);
        return synthloan.mintingfee;
    }

    
    function calculateamounttoliquidate(uint debtbalance, uint collateral) public view returns (uint) {
        uint unit = safedecimalmath.unit();
        uint ratio = liquidationratio;

        uint dividend = debtbalance.sub(collateral.dividedecimal(ratio));
        uint divisor = unit.sub(unit.add(liquidationpenalty).dividedecimal(ratio));

        return dividend.dividedecimal(divisor);
    }

    function openloanidsbyaccount(address _account) external view returns (uint256[] memory) {
        synthloanstruct[] memory synthloans = accountssynthloans[_account];

        uint256[] memory _openloanids = new uint256[](synthloans.length);
        uint256 _counter = 0;

        for (uint256 i = 0; i < synthloans.length; i++) {
            if (synthloans[i].timeclosed == 0) {
                _openloanids[_counter] = synthloans[i].loanid;
                _counter++;
            }
        }
        
        uint256[] memory _result = new uint256[](_counter);

        
        for (uint256 j = 0; j < _counter; j++) {
            _result[j] = _openloanids[j];
        }
        
        return _result;
    }

    function getloan(address _account, uint256 _loanid)
        external
        view
        returns (
            address account,
            uint256 collateralamount,
            uint256 loanamount,
            uint256 timecreated,
            uint256 loanid,
            uint256 timeclosed,
            uint256 accruedinterest,
            uint256 totalfees
        )
    {
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);
        account = synthloan.account;
        collateralamount = synthloan.collateralamount;
        loanamount = synthloan.loanamount;
        timecreated = synthloan.timecreated;
        loanid = synthloan.loanid;
        timeclosed = synthloan.timeclosed;
        accruedinterest = synthloan.accruedinterest.add(
            accruedinterestonloan(synthloan.loanamount.add(synthloan.accruedinterest), _timesinceinterestaccrual(synthloan))
        );
        totalfees = accruedinterest.add(synthloan.mintingfee);
    }

    function getloancollateralratio(address _account, uint256 _loanid) external view returns (uint256 loancollateralratio) {
        
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);

        (loancollateralratio, , ) = _loancollateralratio(synthloan);
    }

    function _loancollateralratio(synthloanstruct memory _loan)
        internal
        view
        returns (
            uint256 loancollateralratio,
            uint256 collateralvalue,
            uint256 interestamount
        )
    {
        
        uint256 loanamountwithaccruedinterest = _loan.loanamount.add(_loan.accruedinterest);

        interestamount = accruedinterestonloan(loanamountwithaccruedinterest, _timesinceinterestaccrual(_loan));

        collateralvalue = _loan.collateralamount.multiplydecimal(exchangerates().rateforcurrency(collateral));

        loancollateralratio = collateralvalue.dividedecimal(loanamountwithaccruedinterest.add(interestamount));
    }

    function timesinceinterestaccrualonloan(address _account, uint256 _loanid) external view returns (uint256) {
        
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);

        return _timesinceinterestaccrual(synthloan);
    }

    

    function openloan(uint256 _loanamount)
        external
        payable
        notpaused
        nonreentrant
        ethratenotinvalid
        returns (uint256 loanid)
    {
        systemstatus().requireissuanceactive();

        
        require(
            msg.value >= minloancollateralsize,
            
        );

        
        require(loanliquidationopen == false, );

        
        require(accountssynthloans[msg.sender].length < accountloanlimit, );

        
        uint256 maxloanamount = loanamountfromcollateral(msg.value);

        
        
        require(_loanamount <= maxloanamount, );

        uint256 mintingfee = _calculatemintingfee(_loanamount);
        uint256 loanamountminusfee = _loanamount.sub(mintingfee);

        
        require(totalissuedsynths.add(_loanamount) <= issuelimit, );

        
        loanid = _incrementtotalloanscounter();

        
        synthloanstruct memory synthloan = synthloanstruct({
            account: msg.sender,
            collateralamount: msg.value,
            loanamount: _loanamount,
            mintingfee: mintingfee,
            timecreated: block.timestamp,
            loanid: loanid,
            timeclosed: 0,
            loaninterestrate: interestrate,
            accruedinterest: 0,
            lastinterestaccrued: 0
        });

        
        if (mintingfee > 0) {
            synthsusd().issue(fee_address, mintingfee);
            feepool().recordfeepaid(mintingfee);
        }

        
        accountssynthloans[msg.sender].push(synthloan);

        
        totalissuedsynths = totalissuedsynths.add(_loanamount);

        
        synthsusd().issue(msg.sender, loanamountminusfee);

        
        emit loancreated(msg.sender, loanid, _loanamount);
    }

    function closeloan(uint256 loanid) external nonreentrant ethratenotinvalid {
        _closeloan(msg.sender, loanid, false);
    }

    
    function depositcollateral(address account, uint256 loanid) external payable notpaused {
        require(msg.value > 0, );

        systemstatus().requireissuanceactive();

        
        require(loanliquidationopen == false, );

        
        synthloanstruct memory synthloan = _getloanfromstorage(account, loanid);

        
        _checkloanisopen(synthloan);

        uint256 totalcollateral = synthloan.collateralamount.add(msg.value);

        _updateloancollateral(synthloan, totalcollateral);

        
        emit collateraldeposited(account, loanid, msg.value, totalcollateral);
    }

    
    function withdrawcollateral(uint256 loanid, uint256 withdrawamount) external notpaused nonreentrant ethratenotinvalid {
        require(withdrawamount > 0, );

        systemstatus().requireissuanceactive();

        
        require(loanliquidationopen == false, );

        
        synthloanstruct memory synthloan = _getloanfromstorage(msg.sender, loanid);

        
        _checkloanisopen(synthloan);

        uint256 collateralafter = synthloan.collateralamount.sub(withdrawamount);

        synthloanstruct memory loanafter = _updateloancollateral(synthloan, collateralafter);

        
        (uint256 collateralratioafter, , ) = _loancollateralratio(loanafter);

        require(collateralratioafter > liquidationratio, );

        
        msg.sender.transfer(withdrawamount);

        
        emit collateralwithdrawn(msg.sender, loanid, withdrawamount, loanafter.collateralamount);
    }

    function repayloan(
        address _loancreatorsaddress,
        uint256 _loanid,
        uint256 _repayamount
    ) external ethratenotinvalid {
        systemstatus().requiresystemactive();

        
        require(ierc20(address(synthsusd())).balanceof(msg.sender) >= _repayamount, );

        synthloanstruct memory synthloan = _getloanfromstorage(_loancreatorsaddress, _loanid);

        
        _checkloanisopen(synthloan);

        
        uint256 loanamountwithaccruedinterest = synthloan.loanamount.add(synthloan.accruedinterest);
        uint256 interestamount = accruedinterestonloan(loanamountwithaccruedinterest, _timesinceinterestaccrual(synthloan));

        
        
        uint256 accruedinterest = synthloan.accruedinterest.add(interestamount);

        (
            uint256 interestpaid,
            uint256 loanamountpaid,
            uint256 accruedinterestafter,
            uint256 loanamountafter
        ) = _splitinterestloanpayment(_repayamount, accruedinterest, synthloan.loanamount);

        
        synthsusd().burn(msg.sender, _repayamount);

        
        _processinterestandloanpayment(interestpaid, loanamountpaid);

        
        _updateloan(synthloan, loanamountafter, accruedinterestafter, block.timestamp);

        emit loanrepaid(_loancreatorsaddress, _loanid, _repayamount, loanamountafter);
    }

    
    function liquidateloan(
        address _loancreatorsaddress,
        uint256 _loanid,
        uint256 _debttocover
    ) external nonreentrant ethratenotinvalid {
        systemstatus().requiresystemactive();

        
        require(ierc20(address(synthsusd())).balanceof(msg.sender) >= _debttocover, );

        synthloanstruct memory synthloan = _getloanfromstorage(_loancreatorsaddress, _loanid);

        
        _checkloanisopen(synthloan);

        (uint256 collateralratio, uint256 collateralvalue, uint256 interestamount) = _loancollateralratio(synthloan);

        require(collateralratio < liquidationratio, );

        
        uint256 liquidationamount = calculateamounttoliquidate(
            synthloan.loanamount.add(synthloan.accruedinterest).add(interestamount),
            collateralvalue
        );

        
        uint256 amounttoliquidate = liquidationamount < _debttocover ? liquidationamount : _debttocover;

        
        synthsusd().burn(msg.sender, amounttoliquidate);

        (uint256 interestpaid, uint256 loanamountpaid, uint256 accruedinterestafter, ) = _splitinterestloanpayment(
            amounttoliquidate,
            synthloan.accruedinterest.add(interestamount),
            synthloan.loanamount
        );

        
        _processinterestandloanpayment(interestpaid, loanamountpaid);

        
        uint256 collateralredeemed = exchangerates().effectivevalue(susd, amounttoliquidate, collateral);

        
        uint256 totalcollateralliquidated = collateralredeemed.multiplydecimal(
            safedecimalmath.unit().add(liquidationpenalty)
        );

        
        _updateloan(synthloan, synthloan.loanamount.sub(loanamountpaid), accruedinterestafter, block.timestamp);

        
        _updateloancollateral(synthloan, synthloan.collateralamount.sub(totalcollateralliquidated));

        
        msg.sender.transfer(totalcollateralliquidated);

        
        emit loanpartiallyliquidated(
            _loancreatorsaddress,
            _loanid,
            msg.sender,
            amounttoliquidate,
            totalcollateralliquidated
        );
    }

    function _splitinterestloanpayment(
        uint256 _paymentamount,
        uint256 _accruedinterest,
        uint256 _loanamount
    )
        internal
        pure
        returns (
            uint256 interestpaid,
            uint256 loanamountpaid,
            uint256 accruedinterestafter,
            uint256 loanamountafter
        )
    {
        uint256 remainingpayment = _paymentamount;

        
        accruedinterestafter = _accruedinterest;
        if (remainingpayment > 0 && _accruedinterest > 0) {
            
            interestpaid = remainingpayment > _accruedinterest ? _accruedinterest : remainingpayment;
            accruedinterestafter = accruedinterestafter.sub(interestpaid);
            remainingpayment = remainingpayment.sub(interestpaid);
        }

        
        loanamountafter = _loanamount;
        if (remainingpayment > 0) {
            loanamountafter = loanamountafter.sub(remainingpayment);
            loanamountpaid = remainingpayment;
        }
    }

    function _processinterestandloanpayment(uint256 interestpaid, uint256 loanamountpaid) internal {
        
        if (interestpaid > 0) {
            synthsusd().issue(fee_address, interestpaid);
            feepool().recordfeepaid(interestpaid);
        }

        
        if (loanamountpaid > 0) {
            totalissuedsynths = totalissuedsynths.sub(loanamountpaid);
        }
    }

    
    function liquidateunclosedloan(address _loancreatorsaddress, uint256 _loanid) external nonreentrant ethratenotinvalid {
        require(loanliquidationopen, );
        
        _closeloan(_loancreatorsaddress, _loanid, true);
        
        emit loanliquidated(_loancreatorsaddress, _loanid, msg.sender);
    }

    

    function _closeloan(
        address account,
        uint256 loanid,
        bool liquidation
    ) private {
        systemstatus().requireissuanceactive();

        
        synthloanstruct memory synthloan = _getloanfromstorage(account, loanid);

        
        _checkloanisopen(synthloan);

        
        
        uint256 interestamount = accruedinterestonloan(
            synthloan.loanamount.add(synthloan.accruedinterest),
            _timesinceinterestaccrual(synthloan)
        );
        uint256 repayamount = synthloan.loanamount.add(interestamount);

        uint256 totalaccruedinterest = synthloan.accruedinterest.add(interestamount);

        require(
            ierc20(address(synthsusd())).balanceof(msg.sender) >= repayamount,
            
        );

        
        _recordloanclosure(synthloan);

        
        
        totalissuedsynths = totalissuedsynths.sub(synthloan.loanamount.sub(synthloan.accruedinterest));

        
        synthsusd().burn(msg.sender, repayamount);

        
        synthsusd().issue(fee_address, totalaccruedinterest);
        feepool().recordfeepaid(totalaccruedinterest);

        uint256 remainingcollateral = synthloan.collateralamount;

        if (liquidation) {
            
            uint256 collateralredeemed = exchangerates().effectivevalue(susd, repayamount, collateral);

            
            uint256 totalcollateralliquidated = collateralredeemed.multiplydecimal(
                safedecimalmath.unit().add(liquidationpenalty)
            );

            
            
            remainingcollateral = remainingcollateral.sub(totalcollateralliquidated);

            
            msg.sender.transfer(totalcollateralliquidated);
        }

        
        synthloan.account.transfer(remainingcollateral);

        
        emit loanclosed(account, loanid, totalaccruedinterest);
    }

    function _getloanfromstorage(address account, uint256 loanid) private view returns (synthloanstruct memory) {
        synthloanstruct[] memory synthloans = accountssynthloans[account];
        for (uint256 i = 0; i < synthloans.length; i++) {
            if (synthloans[i].loanid == loanid) {
                return synthloans[i];
            }
        }
    }

    function _updateloan(
        synthloanstruct memory _synthloan,
        uint256 _newloanamount,
        uint256 _newaccruedinterest,
        uint256 _lastinterestaccrued
    ) private {
        
        synthloanstruct[] storage synthloans = accountssynthloans[_synthloan.account];
        for (uint256 i = 0; i < synthloans.length; i++) {
            if (synthloans[i].loanid == _synthloan.loanid) {
                synthloans[i].loanamount = _newloanamount;
                synthloans[i].accruedinterest = _newaccruedinterest;
                synthloans[i].lastinterestaccrued = uint40(_lastinterestaccrued);
            }
        }
    }

    function _updateloancollateral(synthloanstruct memory _synthloan, uint256 _newcollateralamount)
        private
        returns (synthloanstruct memory)
    {
        
        synthloanstruct[] storage synthloans = accountssynthloans[_synthloan.account];
        for (uint256 i = 0; i < synthloans.length; i++) {
            if (synthloans[i].loanid == _synthloan.loanid) {
                synthloans[i].collateralamount = _newcollateralamount;
                return synthloans[i];
            }
        }
    }

    function _recordloanclosure(synthloanstruct memory synthloan) private {
        
        synthloanstruct[] storage synthloans = accountssynthloans[synthloan.account];
        for (uint256 i = 0; i < synthloans.length; i++) {
            if (synthloans[i].loanid == synthloan.loanid) {
                
                synthloans[i].timeclosed = block.timestamp;
            }
        }

        
        totalopenloancount = totalopenloancount.sub(1);
    }

    function _incrementtotalloanscounter() private returns (uint256) {
        
        totalopenloancount = totalopenloancount.add(1);
        
        totalloanscreated = totalloanscreated.add(1);
        
        return totalloanscreated;
    }

    function _calculatemintingfee(uint256 _loanamount) private view returns (uint256 mintingfee) {
        mintingfee = _loanamount.multiplydecimalround(issuefeerate);
    }

    function _timesinceinterestaccrual(synthloanstruct memory _synthloan) private view returns (uint256 timesinceaccrual) {
        
        
        uint256 lastinterestaccrual = _synthloan.lastinterestaccrued > 0
            ? uint256(_synthloan.lastinterestaccrued)
            : _synthloan.timecreated;

        
        
        timesinceaccrual = _synthloan.timeclosed > 0
            ? _synthloan.timeclosed.sub(lastinterestaccrual)
            : block.timestamp.sub(lastinterestaccrual);
    }

    function _checkloanisopen(synthloanstruct memory _synthloan) internal pure {
        require(_synthloan.loanid > 0, );
        require(_synthloan.timeclosed == 0, );
    }

    

    function systemstatus() internal view returns (isystemstatus) {
        return isystemstatus(requireandgetaddress(contract_systemstatus, ));
    }

    function synthsusd() internal view returns (isynth) {
        return isynth(requireandgetaddress(contract_synthsusd, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    function feepool() internal view returns (ifeepool) {
        return ifeepool(requireandgetaddress(contract_feepool, ));
    }

    

    modifier ethratenotinvalid() {
        require(!exchangerates().rateisinvalid(collateral), );
        _;
    }

    

    event collateralizationratioupdated(uint256 ratio);
    event liquidationratioupdated(uint256 ratio);
    event interestrateupdated(uint256 interestrate);
    event issuefeerateupdated(uint256 issuefeerate);
    event issuelimitupdated(uint256 issuelimit);
    event minloancollateralsizeupdated(uint256 minloancollateralsize);
    event accountloanlimitupdated(uint256 loanlimit);
    event loanliquidationopenupdated(bool loanliquidationopen);
    event loancreated(address indexed account, uint256 loanid, uint256 amount);
    event loanclosed(address indexed account, uint256 loanid, uint256 feespaid);
    event loanliquidated(address indexed account, uint256 loanid, address liquidator);
    event loanpartiallyliquidated(
        address indexed account,
        uint256 loanid,
        address liquidator,
        uint256 liquidatedamount,
        uint256 liquidatedcollateral
    );
    event collateraldeposited(address indexed account, uint256 loanid, uint256 collateralamount, uint256 collateralafter);
    event collateralwithdrawn(address indexed account, uint256 loanid, uint256 amountwithdrawn, uint256 collateralafter);
    event loanrepaid(address indexed account, uint256 loanid, uint256 repaidamount, uint256 newloanamount);
}
