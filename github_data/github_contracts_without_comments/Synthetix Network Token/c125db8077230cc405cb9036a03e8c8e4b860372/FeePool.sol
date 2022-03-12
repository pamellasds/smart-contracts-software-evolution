

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;

contract feepool is proxyable, selfdestructible {

    using safemath for uint;
    using safedecimalmath for uint;

    synthetix public synthetix;

    
    uint public transferfeerate;

    
    uint constant public max_transfer_fee_rate = safedecimalmath.unit() / 10;

    
    uint public exchangefeerate;

    
    uint constant public max_exchange_fee_rate = safedecimalmath.unit() / 10;

    
    address public feeauthority;

    
    address public constant fee_address = 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef;

    
    struct feeperiod {
        uint feeperiodid;
        uint startingdebtindex;
        uint starttime;
        uint feestodistribute;
        uint feesclaimed;
    }

    
    
    
    
    uint8 constant public fee_period_length = 6;
    feeperiod[fee_period_length] public recentfeeperiods;

    
    uint public nextfeeperiodid;

    
    
    
    
    uint public feeperiodduration = 1 weeks;

    
    uint public constant min_fee_period_duration = 1 days;
    uint public constant max_fee_period_duration = 60 days;

    
    mapping(address => uint) public lastfeewithdrawal;

    
    
    uint constant twenty_percent = (20 * safedecimalmath.unit()) / 100;
    uint constant twenty_five_percent = (25 * safedecimalmath.unit()) / 100;
    uint constant thirty_percent = (30 * safedecimalmath.unit()) / 100;
    uint constant fourty_percent = (40 * safedecimalmath.unit()) / 100;
    uint constant fifty_percent = (50 * safedecimalmath.unit()) / 100;
    uint constant seventy_five_percent = (75 * safedecimalmath.unit()) / 100;

    constructor(address _proxy, address _owner, synthetix _synthetix, address _feeauthority, uint _transferfeerate, uint _exchangefeerate)
        selfdestructible(_owner)
        proxyable(_proxy, _owner)
        public
    {
        
        require(_transferfeerate <= max_transfer_fee_rate, );
        require(_exchangefeerate <= max_exchange_fee_rate, );

        synthetix = _synthetix;
        feeauthority = _feeauthority;
        transferfeerate = _transferfeerate;
        exchangefeerate = _exchangefeerate;

        
        recentfeeperiods[0].feeperiodid = 1;
        recentfeeperiods[0].starttime = now;
        
        
        

        
        nextfeeperiodid = 2;
    }

    
    function setexchangefeerate(uint _exchangefeerate)
        external
        optionalproxy_onlyowner
    {
        require(_exchangefeerate <= max_exchange_fee_rate, );

        exchangefeerate = _exchangefeerate;

        emitexchangefeeupdated(_exchangefeerate);
    }

    
    function settransferfeerate(uint _transferfeerate)
        external
        optionalproxy_onlyowner
    {
        require(_transferfeerate <= max_transfer_fee_rate, );

        transferfeerate = _transferfeerate;

        emittransferfeeupdated(_transferfeerate);
    }

    
    function setfeeauthority(address _feeauthority)
        external
        optionalproxy_onlyowner
    {
        feeauthority = _feeauthority;

        emitfeeauthorityupdated(_feeauthority);
    }

    
    function setfeeperiodduration(uint _feeperiodduration)
        external
        optionalproxy_onlyowner
    {
        require(_feeperiodduration >= min_fee_period_duration, );
        require(_feeperiodduration <= max_fee_period_duration, );

        feeperiodduration = _feeperiodduration;

        emitfeeperioddurationupdated(_feeperiodduration);
    }

    
    function setsynthetix(synthetix _synthetix)
        external
        optionalproxy_onlyowner
    {
        require(address(_synthetix) != address(0), );

        synthetix = _synthetix;

        emitsynthetixupdated(_synthetix);
    }

    
    function feepaid(bytes4 currencykey, uint amount)
        external
        onlysynthetix
    {
        uint xdramount = synthetix.effectivevalue(currencykey, amount, );

        
        recentfeeperiods[0].feestodistribute = recentfeeperiods[0].feestodistribute.add(xdramount);
    }

    
    function closecurrentfeeperiod()
        external
        onlyfeeauthority
    {
        require(recentfeeperiods[0].starttime <= (now  feeperiodduration), );

        feeperiod memory secondlastfeeperiod = recentfeeperiods[fee_period_length  2];
        feeperiod memory lastfeeperiod = recentfeeperiods[fee_period_length  1];

        
        
        
        
        
        recentfeeperiods[fee_period_length  2].feestodistribute = lastfeeperiod.feestodistribute
            .sub(lastfeeperiod.feesclaimed)
            .add(secondlastfeeperiod.feestodistribute);

        
        
        
        
        
        for (uint i = fee_period_length  2; i < fee_period_length; i) {
            uint next = i + 1;

            recentfeeperiods[next].feeperiodid = recentfeeperiods[i].feeperiodid;
            recentfeeperiods[next].startingdebtindex = recentfeeperiods[i].startingdebtindex;
            recentfeeperiods[next].starttime = recentfeeperiods[i].starttime;
            recentfeeperiods[next].feestodistribute = recentfeeperiods[i].feestodistribute;
            recentfeeperiods[next].feesclaimed = recentfeeperiods[i].feesclaimed;
        }

        
        delete recentfeeperiods[0];

        
        recentfeeperiods[0].feeperiodid = nextfeeperiodid;
        recentfeeperiods[0].startingdebtindex = synthetix.synthetixstate().debtledgerlength();
        recentfeeperiods[0].starttime = now;

        nextfeeperiodid = nextfeeperiodid.add(1);

        emitfeeperiodclosed(recentfeeperiods[1].feeperiodid);
    }

    
    function claimfees(bytes4 currencykey)
        external
        optionalproxy
        returns (bool)
    {
        uint availablefees = feesavailable(messagesender, );

        require(availablefees > 0, );

        lastfeewithdrawal[messagesender] = recentfeeperiods[1].feeperiodid;

        
        _recordfeepayment(availablefees);

        
        _payfees(messagesender, availablefees, currencykey);

        emitfeesclaimed(messagesender, availablefees);

        return true;
    }

    
    function _recordfeepayment(uint xdramount)
        internal
    {
        
        uint remainingtoallocate = xdramount;

        
        
        
        for (uint i = fee_period_length  1; i < fee_period_length; i) {
            uint delta = recentfeeperiods[i].feestodistribute.sub(recentfeeperiods[i].feesclaimed);

            if (delta > 0) {
                
                uint amountinperiod = delta < remainingtoallocate ? delta : remainingtoallocate;

                recentfeeperiods[i].feesclaimed = recentfeeperiods[i].feesclaimed.add(amountinperiod);
                remainingtoallocate = remainingtoallocate.sub(amountinperiod);

                
                if (remainingtoallocate == 0) return;
            }
        }

        
        
        assert(remainingtoallocate == 0);
    }

    
    function _payfees(address account, uint xdramount, bytes4 destinationcurrencykey)
        internal
        notfeeaddress(account)
    {
        require(account != address(0), );
        require(account != address(this), );
        require(account != address(proxy), );
        require(account != address(synthetix), );

        synth xdrsynth = synthetix.synths();
        synth destinationsynth = synthetix.synths(destinationcurrencykey);

        
        

        
        xdrsynth.burn(fee_address, xdramount);

        
        uint destinationamount = synthetix.effectivevalue(, xdramount, destinationcurrencykey);

        

        
        destinationsynth.issue(account, destinationamount);

        

        
        destinationsynth.triggertokenfallbackifneeded(fee_address, account, destinationamount);
    }

    
    function transferfeeincurred(uint value)
        public
        view
        returns (uint)
    {
        return value.multiplydecimal(transferfeerate);

        
        
        
        
        
        
        
    }

    
    function transferredamounttoreceive(uint value)
        external
        view
        returns (uint)
    {
        return value.add(transferfeeincurred(value));
    }

    
    function amountreceivedfromtransfer(uint value)
        external
        view
        returns (uint)
    {
        return value.dividedecimal(transferfeerate.add(safedecimalmath.unit()));
    }

    
    function exchangefeeincurred(uint value)
        public
        view
        returns (uint)
    {
        return value.multiplydecimal(exchangefeerate);

        
        
        
        
        
        
        
    }

    
    function exchangedamounttoreceive(uint value)
        external
        view
        returns (uint)
    {
        return value.add(exchangefeeincurred(value));
    }

    
    function amountreceivedfromexchange(uint value)
        external
        view
        returns (uint)
    {
        return value.dividedecimal(exchangefeerate.add(safedecimalmath.unit()));
    }

    
    function totalfeesavailable(bytes4 currencykey)
        external
        view
        returns (uint)
    {
        uint totalfees = 0;

        
        for (uint i = 1; i < fee_period_length; i++) {
            totalfees = totalfees.add(recentfeeperiods[i].feestodistribute);
            totalfees = totalfees.sub(recentfeeperiods[i].feesclaimed);
        }

        return synthetix.effectivevalue(, totalfees, currencykey);
    }

    
    function feesavailable(address account, bytes4 currencykey)
        public
        view
        returns (uint)
    {
        
        uint[fee_period_length] memory userfees = feesbyperiod(account);

        uint totalfees = 0;

        
        for (uint i = 1; i < fee_period_length; i++) {
            totalfees = totalfees.add(userfees[i]);
        }

        
        return synthetix.effectivevalue(, totalfees, currencykey);
    }

    
    function currentpenalty(address account)
        public
        view
        returns (uint)
    {
        uint ratio = synthetix.collateralisationratio(account);

        
        
        
        
        
        if (ratio <= twenty_percent) {
            return 0;
        } else if (ratio > twenty_percent && ratio <= thirty_percent) {
            return twenty_five_percent;
        } else if (ratio > thirty_percent && ratio <= fourty_percent) {
            return fifty_percent;
        }

        return seventy_five_percent;
    }

    
    function feesbyperiod(address account)
        public
        view
        returns (uint[fee_period_length])
    {
        uint[fee_period_length] memory result;

        
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = synthetix.synthetixstate().issuancedata(account);

        
        if (initialdebtownership == 0) return result;

        
        uint totalsynths = synthetix.totalissuedsynths();
        if (totalsynths == 0) return result;

        uint debtbalance = synthetix.debtbalanceof(account, );
        uint userownershippercentage = debtbalance.dividedecimal(totalsynths);
        uint penalty = currentpenalty(account);
        
        
        
        
        for (uint i = 0; i < fee_period_length; i++) {
            
            
            
            if (recentfeeperiods[i].startingdebtindex > debtentryindex &&
                lastfeewithdrawal[account] < recentfeeperiods[i].feeperiodid) {

                
                uint feesfromperiodwithoutpenalty = recentfeeperiods[i].feestodistribute
                    .multiplydecimal(userownershippercentage);

                
                uint penaltyfromperiod = feesfromperiodwithoutpenalty.multiplydecimal(penalty);
                uint feesfromperiod = feesfromperiodwithoutpenalty.sub(penaltyfromperiod);

                result[i] = feesfromperiod;
            }
        }

        return result;
    }

    modifier onlyfeeauthority
    {
        require(msg.sender == feeauthority, );
        _;
    }

    modifier onlysynthetix
    {
        require(msg.sender == address(synthetix), );
        _;
    }

    modifier notfeeaddress(address account) {
        require(account != fee_address, );
        _;
    }

    event transferfeeupdated(uint newfeerate);
    bytes32 constant transferfeeupdated_sig = keccak256();
    function emittransferfeeupdated(uint newfeerate) internal {
        proxy._emit(abi.encode(newfeerate), 1, transferfeeupdated_sig, 0, 0, 0);
    }

    event exchangefeeupdated(uint newfeerate);
    bytes32 constant exchangefeeupdated_sig = keccak256();
    function emitexchangefeeupdated(uint newfeerate) internal {
        proxy._emit(abi.encode(newfeerate), 1, exchangefeeupdated_sig, 0, 0, 0);
    }

    event feeperioddurationupdated(uint newfeeperiodduration);
    bytes32 constant feeperioddurationupdated_sig = keccak256();
    function emitfeeperioddurationupdated(uint newfeeperiodduration) internal {
        proxy._emit(abi.encode(newfeeperiodduration), 1, feeperioddurationupdated_sig, 0, 0, 0);
    }

    event feeauthorityupdated(address newfeeauthority);
    bytes32 constant feeauthorityupdated_sig = keccak256();
    function emitfeeauthorityupdated(address newfeeauthority) internal {
        proxy._emit(abi.encode(newfeeauthority), 1, feeauthorityupdated_sig, 0, 0, 0);
    }

    event feeperiodclosed(uint feeperiodid);
    bytes32 constant feeperiodclosed_sig = keccak256();
    function emitfeeperiodclosed(uint feeperiodid) internal {
        proxy._emit(abi.encode(feeperiodid), 1, feeperiodclosed_sig, 0, 0, 0);
    }

    event feesclaimed(address account, uint xdramount);
    bytes32 constant feesclaimed_sig = keccak256();
    function emitfeesclaimed(address account, uint xdramount) internal {
        proxy._emit(abi.encode(account, xdramount), 1, feesclaimed_sig, 0, 0, 0);
    }

    event synthetixupdated(address newsynthetix);
    bytes32 constant synthetixupdated_sig = keccak256();
    function emitsynthetixupdated(address newsynthetix) internal {
        proxy._emit(abi.encode(newsynthetix), 1, synthetixupdated_sig, 0, 0, 0);
    }
}
