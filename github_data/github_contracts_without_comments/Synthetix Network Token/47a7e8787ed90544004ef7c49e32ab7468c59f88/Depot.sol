

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;


contract depot is selfdestructible, pausable {
    using safemath for uint;
    using safedecimalmath for uint;

    
    address public snxproxy;
    isynth public synth;
    ifeepool public feepool;

    
    
    
    address public fundswallet;

    
    address public oracle;
    
    uint public constant oracle_future_limit = 10 minutes;

    
    uint public pricestaleperiod = 3 hours;

    
    uint public lastpriceupdatetime;
    
    uint public usdtosnxprice;
    
    uint public usdtoethprice;

    
    struct synthdeposit {
        
        address user;
        
        uint amount;
    }

    
    mapping(uint => synthdeposit) public deposits;
    
    uint public depositstartindex;
    
    uint public depositendindex;

    
    uint public totalsellabledeposits;

    
    uint public minimumdepositamount = 50 * safedecimalmath.unit();

    
    
    
    mapping(address => uint) public smalldeposits;


    

    
    constructor(
        
        address _owner,

        
        address _fundswallet,

        
        address _snxproxy,
        isynth _synth,
        ifeepool _feepool,

        
        address _oracle,
        uint _usdtoethprice,
        uint _usdtosnxprice
    )
        
        selfdestructible(_owner)
        pausable(_owner)
        public
    {
        fundswallet = _fundswallet;
        snxproxy = _snxproxy;
        synth = _synth;
        feepool = _feepool;
        oracle = _oracle;
        usdtoethprice = _usdtoethprice;
        usdtosnxprice = _usdtosnxprice;
        lastpriceupdatetime = now;
    }

    

    
    function setfundswallet(address _fundswallet)
        external
        onlyowner
    {
        fundswallet = _fundswallet;
        emit fundswalletupdated(fundswallet);
    }

    
    function setoracle(address _oracle)
        external
        onlyowner
    {
        oracle = _oracle;
        emit oracleupdated(oracle);
    }

    
    function setsynth(isynth _synth)
        external
        onlyowner
    {
        synth = _synth;
        emit synthupdated(_synth);
    }

    
    function setsynthetix(address _snxproxy)
        external
        onlyowner
    {
        snxproxy = _snxproxy;
        emit synthetixupdated(snxproxy);
    }

    
    function setpricestaleperiod(uint _time)
        external
        onlyowner
    {
        pricestaleperiod = _time;
        emit pricestaleperiodupdated(pricestaleperiod);
    }

    
    function setminimumdepositamount(uint _amount)
        external
        onlyowner
    {
        
        require(_amount > safedecimalmath.unit(), );
        minimumdepositamount = _amount;
        emit minimumdepositamountupdated(minimumdepositamount);
    }

    
    
    function updateprices(uint newethprice, uint newsynthetixprice, uint timesent)
        external
        onlyoracle
    {
        
        require(lastpriceupdatetime < timesent, );
        require(timesent < (now + oracle_future_limit), );

        usdtoethprice = newethprice;
        usdtosnxprice = newsynthetixprice;
        lastpriceupdatetime = timesent;

        emit pricesupdated(usdtoethprice, usdtosnxprice, lastpriceupdatetime);
    }

    
    function ()
        external
        payable
    {
        exchangeetherforsynths();
    }

    
    function exchangeetherforsynths()
        public
        payable
        pricesnotstale
        notpaused
        returns (uint) 
    {
        uint ethtosend;

        
        
        uint requestedtopurchase = msg.value.multiplydecimal(usdtoethprice);
        uint remainingtofulfill = requestedtopurchase;

        
        for (uint i = depositstartindex; remainingtofulfill > 0 && i < depositendindex; i++) {
            synthdeposit memory deposit = deposits[i];

            
            
            if (deposit.user == address(0)) {

                depositstartindex = depositstartindex.add(1);
            } else {
                
                
                if (deposit.amount > remainingtofulfill) {

                    
                    
                    
                    uint newamount = deposit.amount.sub(remainingtofulfill);
                    deposits[i] = synthdeposit({ user: deposit.user, amount: newamount});

                    totalsellabledeposits = totalsellabledeposits.sub(remainingtofulfill);

                    
                    
                    
                    
                    
                    ethtosend = remainingtofulfill.dividedecimal(usdtoethprice);

                    
                    
                    
                    
                    if(!deposit.user.send(ethtosend)) {
                        fundswallet.transfer(ethtosend);
                        emit nonpayablecontract(deposit.user, ethtosend);
                    } else {
                        emit cleareddeposit(msg.sender, deposit.user, ethtosend, remainingtofulfill, i);
                    }

                    
                    
                    
                    
                    synth.transfer(msg.sender, remainingtofulfill);

                    
                    remainingtofulfill = 0;
                } else if (deposit.amount <= remainingtofulfill) {
                    
                    
                    
                    delete deposits[i];
                    
                    depositstartindex = depositstartindex.add(1);
                    
                    totalsellabledeposits = totalsellabledeposits.sub(deposit.amount);

                    
                    
                    
                    
                    
                    ethtosend = deposit.amount.dividedecimal(usdtoethprice);

                    
                    
                    
                    
                    if(!deposit.user.send(ethtosend)) {
                        fundswallet.transfer(ethtosend);
                        emit nonpayablecontract(deposit.user, ethtosend);
                    } else {
                        emit cleareddeposit(msg.sender, deposit.user, ethtosend, deposit.amount, i);
                    }

                    
                    
                    
                    
                    synth.transfer(msg.sender, deposit.amount);

                    
                    
                    remainingtofulfill = remainingtofulfill.sub(deposit.amount);
                }
            }
        }

        
        
        if (remainingtofulfill > 0) {
            msg.sender.transfer(remainingtofulfill.dividedecimal(usdtoethprice));
        }

        
        uint fulfilled = requestedtopurchase.sub(remainingtofulfill);

        if (fulfilled > 0) {
            
            emit exchange(, msg.value, , fulfilled);
        }

        return fulfilled;
    }

    
    function exchangeetherforsynthsatrate(uint guaranteedrate)
        public
        payable
        pricesnotstale
        notpaused
        returns (uint) 
    {
        require(guaranteedrate == usdtoethprice, );

        return exchangeetherforsynths();
    }


    
    function exchangeetherforsnx()
        public
        payable
        pricesnotstale
        notpaused
        returns (uint) 
    {
        
        uint synthetixtosend = synthetixreceivedforether(msg.value);

        
        fundswallet.transfer(msg.value);

        
        ierc20(snxproxy).transfer(msg.sender, synthetixtosend);

        emit exchange(, msg.value, , synthetixtosend);

        return synthetixtosend;
    }

    
    function exchangeetherforsynthetixatrate(uint guaranteedetherrate, uint guaranteedsynthetixrate)
        public
        payable
        pricesnotstale
        notpaused
        returns (uint) 
    {
        require(guaranteedetherrate == usdtoethprice, );
        require(guaranteedsynthetixrate == usdtosnxprice, );

        return exchangeetherforsnx();
    }


    
    function exchangesynthsforsynthetix(uint synthamount)
        public
        pricesnotstale
        notpaused
        returns (uint) 
    {
        
        uint synthetixtosend = synthetixreceivedforsynths(synthamount);

        
        
        
        synth.transferfrom(msg.sender, fundswallet, synthamount);

        
        ierc20(snxproxy).transfer(msg.sender, synthetixtosend);

        emit exchange(, synthamount, , synthetixtosend);

        return synthetixtosend;
    }

    
    function exchangesynthsforsynthetixatrate(uint synthamount, uint guaranteedrate)
        public
        pricesnotstale
        notpaused
        returns (uint) 
    {
        require(guaranteedrate == usdtosnxprice, );

        return exchangesynthsforsynthetix(synthamount);
    }

    
    function withdrawsynthetix(uint amount)
        external
        onlyowner
    {
        ierc20(snxproxy).transfer(owner, amount);

        
        
        
        
    }

    
    function withdrawmydepositedsynths()
        external
    {
        uint synthstosend = 0;

        for (uint i = depositstartindex; i < depositendindex; i++) {
            synthdeposit memory deposit = deposits[i];

            if (deposit.user == msg.sender) {
                
                
                synthstosend = synthstosend.add(deposit.amount);
                delete deposits[i];
                
                emit synthdepositremoved(deposit.user, deposit.amount, i);
            }
        }

        
        totalsellabledeposits = totalsellabledeposits.sub(synthstosend);

        
        
        synthstosend = synthstosend.add(smalldeposits[msg.sender]);
        smalldeposits[msg.sender] = 0;

        
        require(synthstosend > 0, );

        
        synth.transfer(msg.sender, synthstosend);

        emit synthwithdrawal(msg.sender, synthstosend);
    }

    
    function depositsynths(uint amount)
        external
    {
        
        synth.transferfrom(msg.sender, this, amount);

        
        
        if (amount < minimumdepositamount) {
            
            
            smalldeposits[msg.sender] = smalldeposits[msg.sender].add(amount);

            emit synthdepositnotaccepted(msg.sender, amount, minimumdepositamount);
        } else {
            
            deposits[depositendindex] = synthdeposit({ user: msg.sender, amount: amount });
            emit synthdeposit(msg.sender, amount, depositendindex);

            
            depositendindex = depositendindex.add(1);

            
            totalsellabledeposits = totalsellabledeposits.add(amount);
        }
    }

    
    
    function pricesarestale()
        public
        view
        returns (bool)
    {
        return lastpriceupdatetime.add(pricestaleperiod) < now;
    }

    
    function synthetixreceivedforsynths(uint amount)
        public
        view
        returns (uint)
    {
        
        uint synthsreceived = feepool.amountreceivedfromtransfer(amount);

        
        return synthsreceived.dividedecimal(usdtosnxprice);
    }

    
    function synthetixreceivedforether(uint amount)
        public
        view
        returns (uint)
    {
        
        uint valuesentinsynths = amount.multiplydecimal(usdtoethprice);

        
        return synthetixreceivedforsynths(valuesentinsynths);
    }

    
    function synthsreceivedforether(uint amount)
        public
        view
        returns (uint)
    {
        
        uint synthstransferred = amount.multiplydecimal(usdtoethprice);

        
        return feepool.amountreceivedfromtransfer(synthstransferred);
    }

    

    modifier onlyoracle
    {
        require(msg.sender == oracle, );
        _;
    }

    modifier onlysynth
    {
        
        require(msg.sender == address(synth), );
        _;
    }

    modifier pricesnotstale
    {
        require(!pricesarestale(), );
        _;
    }

    

    event fundswalletupdated(address newfundswallet);
    event oracleupdated(address neworacle);
    event synthupdated(isynth newsynthcontract);
    event synthetixupdated(address newsnxproxy);
    event pricestaleperiodupdated(uint pricestaleperiod);
    event pricesupdated(uint newethprice, uint newsynthetixprice, uint timesent);
    event exchange(string fromcurrency, uint fromamount, string tocurrency, uint toamount);
    event synthwithdrawal(address user, uint amount);
    event synthdeposit(address indexed user, uint amount, uint indexed depositindex);
    event synthdepositremoved(address indexed user, uint amount, uint indexed depositindex);
    event synthdepositnotaccepted(address user, uint amount, uint minimum);
    event minimumdepositamountupdated(uint amount);
    event nonpayablecontract(address indexed receiver, uint amount);
    event cleareddeposit(address indexed fromaddress, address indexed toaddress, uint fromethamount, uint toamount, uint indexed depositindex);
}
