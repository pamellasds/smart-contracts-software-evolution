pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract ethercollateral is owned, pausable, reentrancyguard, mixinresolver {
    using safemath for uint256;
    using safedecimalmath for uint256;

    

    uint256 constant one_thousand = safedecimalmath.unit() * 1000;
    uint256 constant one_hundred = safedecimalmath.unit() * 100;

    uint256 constant seconds_in_a_year = 31536000; 

    
    address constant fee_address = 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef;

    

    
    uint256 public collateralizationratio = safedecimalmath.unit() * 150;

    
    uint256 public interestrate = (5 * safedecimalmath.unit()) / 100;
    uint256 public interestpersecond = interestrate.div(seconds_in_a_year);

    
    uint256 public issuefeerate = (5 * safedecimalmath.unit()) / 1000;

    
    uint256 public issuelimit = safedecimalmath.unit() * 5000;

    
    uint256 public minloansize = safedecimalmath.unit() * 1;

    
    bool public loanliquidationopen = false;

    
    uint256 public liquidationdeadline;

    

    
    uint256 public totalissuedsynths;

    
    uint256 public totalloanscreated;

    
    uint256 public totalopenloancount;

    
    struct synthloanstruct {
        
        address account;
        
        uint256 collateralamount;
        
        uint256 loanamount;
        
        uint256 timecreated;
        
        uint256 loanid;
        
        uint256 timeclosed;
    }

    
    mapping(address => synthloanstruct[]) public accountssynthloans;

    
    mapping(address => uint256) public accountopenloanindex;

    
    mapping(address => uint256) public accountopenloancounter;

    
    address[] public accountswithopenloans;

    
    constructor(address _owner, address _resolver) public owned(_owner) pausable(_owner) mixinresolver(_owner, _resolver) {
        liquidationdeadline = now + 92 days; 
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

    function setminloansize(uint256 _minloansize) external onlyowner {
        minloansize = _minloansize;
        emit minloansize(minloansize);
    }

    function setloanliquidationopen(bool _loanliquidationopen) external onlyowner {
        require(now > liquidationdeadline, );
        loanliquidationopen = _loanliquidationopen;
        emit loanliquidationopenupdated(loanliquidationopen);
    }

    

    
    
    
    function issuanceratio() public view returns (uint256) {
        
        
        return one_hundred.dividedecimalround(collateralizationratio);
    }

    function loanamountfromcollateral(uint256 collateralamount) public view returns (uint256) {
        return collateralamount.multiplydecimal(issuanceratio());
    }

    function collateralamountforloan(uint256 loanamount) external view returns (uint256) {
        return loanamount.multiplydecimal(collateralizationratio.dividedecimalround(one_hundred));
    }

    function currentinterestonloan(address _account, uint256 _loanid) external view returns (uint256) {
        
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);
        uint256 loanlifespan = _loanlifespan(synthloan);
        return accruedinterestonloan(synthloan.loanamount, loanlifespan);
    }

    function accruedinterestonloan(uint256 _loanamount, uint256 _seconds) public view returns (uint256 interestamount) {
        
        
        interestamount = _loanamount.multiplydecimalround(interestpersecond.mul(_seconds));
    }

    function calculatemintingfee(address _account, uint256 _loanid) external view returns (uint256) {
        
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);
        return _calculatemintingfee(synthloan);
    }

    function getaccountswithopenloans() external view returns (address[]) {
        
        address[] memory _accountswithopenloans = new address[](accountswithopenloans.length);

        
        for (uint256 i = 0; i < accountswithopenloans.length; i++) {
            _accountswithopenloans[i] = accountswithopenloans[i];
        }
        
        return _accountswithopenloans;
    }

    function openloanidsbyaccount(address _account) external view returns (uint256[]) {
        uint256[] _openloanids;
        uint256 _counter = 0;

        synthloanstruct[] memory synthloans = accountssynthloans[_account];

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
            uint256 interest,
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
        interest = accruedinterestonloan(synthloan.loanamount, _loanlifespan(synthloan));
        totalfees = interest.add(_calculatemintingfee(synthloan));
    }

    function loanlifespan(address _account, uint256 _loanid) external view returns (uint256 loanlifespan) {
        synthloanstruct memory synthloan = _getloanfromstorage(_account, _loanid);
        loanlifespan = _loanlifespan(synthloan);
    }

    

    function openloan() external payable notpaused nonreentrant returns (uint256 loanid) {
        
        require(msg.value >= minloansize, );

        
        require(loanliquidationopen == false, );

        
        uint256 loanamount = loanamountfromcollateral(msg.value);

        
        require(totalissuedsynths.add(loanamount) < issuelimit, );

        
        loanid = _incrementtotalloanscounter();

        
        synthloanstruct memory synthloan = synthloanstruct({
            account: msg.sender,
            collateralamount: msg.value,
            loanamount: loanamount,
            timecreated: now,
            loanid: loanid,
            timeclosed: 0
        });

        
        storeloan(msg.sender, synthloan);

        
        totalissuedsynths = totalissuedsynths.add(loanamount);

        
        synthseth().issue(msg.sender, loanamount);

        
        emit loancreated(msg.sender, loanid, loanamount);
    }

    function closeloan(uint256 loanid) external nonreentrant {
        _closeloan(msg.sender, loanid);
    }

    
    function liquidateunclosedloan(address _loancreatorsaddress, uint256 _loanid) external nonreentrant {
        require(loanliquidationopen, );
        
        _closeloan(_loancreatorsaddress, _loanid);
        
        emit loanliquidated(_loancreatorsaddress, _loanid, msg.sender);
    }

    

    function _closeloan(address account, uint256 loanid) private {
        
        synthloanstruct memory synthloan = _getloanfromstorage(account, loanid);

        require(synthloan.loanid > 0, );
        require(synthloan.timeclosed == 0, );
        require(
            synthseth().balanceof(msg.sender) >= synthloan.loanamount,
            
        );

        
        _recordloanclosure(synthloan);

        
        totalissuedsynths = totalissuedsynths.sub(synthloan.loanamount);

        
        uint256 interestamount = accruedinterestonloan(synthloan.loanamount, _loanlifespan(synthloan));
        uint256 mintingfee = _calculatemintingfee(synthloan);
        uint256 totalfees = interestamount.add(mintingfee);

        
        synthseth().burn(account, synthloan.loanamount);

        
        depot().exchangeetherforsynths.value(totalfees)();

        
        synthsusd().transfer(fee_address, synthsusd().balanceof(this));

        
        address(msg.sender).transfer(synthloan.collateralamount.sub(totalfees));

        
        emit loanclosed(account, loanid, totalfees);
    }

    function storeloan(address account, synthloanstruct synthloan) private {
        
        accountssynthloans[account].push(synthloan);

        
        accountopenloancounter[account] = accountopenloancounter[account].add(1);

        if (accountopenloanindex[account] == 0) {
            
            accountswithopenloans.push(account);
            
            accountopenloanindex[account] = accountswithopenloans.length;
        }
    }

    function _getloanfromstorage(address account, uint256 loanid) private view returns (synthloanstruct) {
        synthloanstruct[] memory synthloans = accountssynthloans[account];
        for (uint256 i = 0; i < synthloans.length; i++) {
            if (synthloans[i].loanid == loanid) {
                return synthloans[i];
            }
        }
    }

    function _recordloanclosure(synthloanstruct synthloan) private {
        
        synthloanstruct[] storage synthloans = accountssynthloans[synthloan.account];
        for (uint256 i = 0; i < synthloans.length; i++) {
            if (synthloans[i].loanid == synthloan.loanid) {
                
                synthloans[i].timeclosed = now;
                
                accountopenloancounter[synthloan.account] = accountopenloancounter[synthloan.account].sub(1);
            }
        }
        
        if (accountopenloancounter[synthloan.account] == 0) {
            _removefromopenloanaccounts(synthloan.account);
        }
        
        totalopenloancount = totalopenloancount.sub(1);
    }

    function _removefromopenloanaccounts(address _account) private {
        
        uint256 index = accountopenloanindex[_account].sub(1);

        if (accountswithopenloans[index] == _account) {
            address accounttoshift = accountswithopenloans[accountswithopenloans.length  1];
            
            accountswithopenloans[index] = accounttoshift;
            
            accountopenloanindex[accounttoshift] = index;
            
            delete accountswithopenloans[accountswithopenloans.length  1];
            accountswithopenloans.length;
        }
    }

    function _incrementtotalloanscounter() private returns (uint256) {
        
        totalopenloancount = totalopenloancount.add(1);
        
        totalloanscreated = totalloanscreated.add(1);
        
        return totalloanscreated;
    }

    function _calculatemintingfee(synthloanstruct synthloan) private view returns (uint256 mintingfee) {
        mintingfee = synthloan.loanamount.multiplydecimalround(issuefeerate);
    }

    function _loanlifespan(synthloanstruct synthloan) private view returns (uint256 loanlifespan) {
        
        bool loanclosed = synthloan.timeclosed > 0;
        
        loanlifespan = loanclosed ? synthloan.timeclosed.sub(synthloan.timecreated) : now.sub(synthloan.timecreated);
    }

    

    function synthseth() internal view returns (isynth) {
        return isynth(resolver.requireandgetaddress(, ));
    }

    function synthsusd() internal view returns (isynth) {
        return isynth(resolver.requireandgetaddress(, ));
    }

    function depot() internal view returns (idepot) {
        return idepot(resolver.requireandgetaddress(, ));
    }

    

    event collateralizationratioupdated(uint256 ratio);
    event interestrateupdated(uint256 interestrate);
    event issuefeerateupdated(uint256 issuefeerate);
    event issuelimitupdated(uint256 issuefeerate);
    event minloansize(uint256 interestrate);
    event loanliquidationopenupdated(bool loanliquidationopen);
    event loancreated(address indexed account, uint256 loanid, uint256 amount);
    event loanclosed(address indexed account, uint256 loanid, uint256 feespaid);
    event loanliquidated(address indexed account, uint256 loanid, address liquidator);
}
