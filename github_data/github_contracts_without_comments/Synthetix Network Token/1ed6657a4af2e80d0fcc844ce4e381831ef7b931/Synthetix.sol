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



contract synthetix is ierc20, externstatetoken, mixinresolver, isynthetix {
    

    
    string public constant token_name = ;
    string public constant token_symbol = ;
    uint8 public constant decimals = 18;
    bytes32 public constant susd = ;

    

    bytes32 private constant contract_systemstatus = ;
    bytes32 private constant contract_exchanger = ;
    bytes32 private constant contract_issuer = ;
    bytes32 private constant contract_exrates = ;
    bytes32 private constant contract_supplyschedule = ;
    bytes32 private constant contract_rewardsdistribution = ;

    bytes32[24] private addressestocache = [
        contract_systemstatus,
        contract_exchanger,
        contract_issuer,
        contract_exrates,
        contract_supplyschedule,
        contract_rewardsdistribution
    ];

    

    constructor(
        address payable _proxy,
        tokenstate _tokenstate,
        address _owner,
        uint _totalsupply,
        address _resolver
    )
        public
        externstatetoken(_proxy, _tokenstate, token_name, token_symbol, _totalsupply, decimals, _owner)
        mixinresolver(_resolver, addressestocache)
    {}

    

    function systemstatus() internal view returns (isystemstatus) {
        return isystemstatus(requireandgetaddress(contract_systemstatus, ));
    }

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(requireandgetaddress(contract_exchanger, ));
    }

    function issuer() internal view returns (iissuer) {
        return iissuer(requireandgetaddress(contract_issuer, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    function supplyschedule() internal view returns (supplyschedule) {
        return supplyschedule(requireandgetaddress(contract_supplyschedule, ));
    }

    function rewardsdistribution() internal view returns (irewardsdistribution) {
        return
            irewardsdistribution(requireandgetaddress(contract_rewardsdistribution, ));
    }

    function debtbalanceof(address account, bytes32 currencykey) external view returns (uint) {
        return issuer().debtbalanceof(account, currencykey);
    }

    function totalissuedsynths(bytes32 currencykey) external view returns (uint) {
        return issuer().totalissuedsynths(currencykey, false);
    }

    function totalissuedsynthsexcludeethercollateral(bytes32 currencykey) external view returns (uint) {
        return issuer().totalissuedsynths(currencykey, true);
    }

    function availablecurrencykeys() external view returns (bytes32[] memory) {
        return issuer().availablecurrencykeys();
    }

    function availablesynthcount() external view returns (uint) {
        return issuer().availablesynthcount();
    }

    function availablesynths(uint index) external view returns (isynth) {
        return issuer().availablesynths(index);
    }

    function synths(bytes32 currencykey) external view returns (isynth) {
        return issuer().synths(currencykey);
    }

    function synthsbyaddress(address synthaddress) external view returns (bytes32) {
        return issuer().synthsbyaddress(synthaddress);
    }

    function iswaitingperiod(bytes32 currencykey) external view returns (bool) {
        return exchanger().maxsecsleftinwaitingperiod(messagesender, currencykey) > 0;
    }

    function anysynthorsnxrateisstale() external view returns (bool anyratestale) {
        return issuer().anysynthorsnxrateisstale();
    }

    function maxissuablesynths(address account) external view returns (uint maxissuable) {
        return issuer().maxissuablesynths(account);
    }

    function remainingissuablesynths(address account)
        external
        view
        returns (
            uint maxissuable,
            uint alreadyissued,
            uint totalsystemdebt
        )
    {
        return issuer().remainingissuablesynths(account);
    }

    

    function transfer(address to, uint value) external optionalproxy systemactive returns (bool) {
        
        (uint transferable, bool anyrateisstale) = issuer().transferablesynthetixandanyrateisstale(
            messagesender,
            tokenstate.balanceof(messagesender)
        );

        require(value <= transferable, );

        require(!anyrateisstale, );

        
        _transferbyproxy(messagesender, to, value);

        return true;
    }

    function transferfrom(
        address from,
        address to,
        uint value
    ) external optionalproxy systemactive returns (bool) {
        
        (uint transferable, bool anyrateisstale) = issuer().transferablesynthetixandanyrateisstale(
            from,
            tokenstate.balanceof(from)
        );

        require(value <= transferable, );

        require(!anyrateisstale, );

        
        
        return _transferfrombyproxy(messagesender, from, to, value);
    }

    function issuesynths(uint amount) external issuanceactive optionalproxy {
        return issuer().issuesynths(messagesender, amount);
    }

    function issuesynthsonbehalf(address issueforaddress, uint amount) external issuanceactive optionalproxy {
        return issuer().issuesynthsonbehalf(issueforaddress, messagesender, amount);
    }

    function issuemaxsynths() external issuanceactive optionalproxy {
        return issuer().issuemaxsynths(messagesender);
    }

    function issuemaxsynthsonbehalf(address issueforaddress) external issuanceactive optionalproxy {
        return issuer().issuemaxsynthsonbehalf(issueforaddress, messagesender);
    }

    function burnsynths(uint amount) external issuanceactive optionalproxy {
        return issuer().burnsynths(messagesender, amount);
    }

    function burnsynthsonbehalf(address burnforaddress, uint amount) external issuanceactive optionalproxy {
        return issuer().burnsynthsonbehalf(burnforaddress, messagesender, amount);
    }

    function burnsynthstotarget() external issuanceactive optionalproxy {
        return issuer().burnsynthstotarget(messagesender);
    }

    function burnsynthstotargetonbehalf(address burnforaddress) external issuanceactive optionalproxy {
        return issuer().burnsynthstotargetonbehalf(burnforaddress, messagesender);
    }

    function exchange(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external exchangeactive(sourcecurrencykey, destinationcurrencykey) optionalproxy returns (uint amountreceived) {
        return exchanger().exchange(messagesender, sourcecurrencykey, sourceamount, destinationcurrencykey, messagesender);
    }

    function exchangeonbehalf(
        address exchangeforaddress,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external exchangeactive(sourcecurrencykey, destinationcurrencykey) optionalproxy returns (uint amountreceived) {
        return
            exchanger().exchangeonbehalf(
                exchangeforaddress,
                messagesender,
                sourcecurrencykey,
                sourceamount,
                destinationcurrencykey
            );
    }

    function settle(bytes32 currencykey)
        external
        optionalproxy
        returns (
            uint reclaimed,
            uint refunded,
            uint numentriessettled
        )
    {
        return exchanger().settle(messagesender, currencykey);
    }

    function collateralisationratio(address _issuer) external view returns (uint) {
        return issuer().collateralisationratio(_issuer);
    }

    function collateral(address account) external view returns (uint) {
        return issuer().collateral(account);
    }

    function transferablesynthetix(address account) external view returns (uint transferable) {
        (transferable, ) = issuer().transferablesynthetixandanyrateisstale(account, tokenstate.balanceof(account));
    }

    function mint() external issuanceactive returns (bool) {
        require(address(rewardsdistribution()) != address(0), );

        supplyschedule _supplyschedule = supplyschedule();
        irewardsdistribution _rewardsdistribution = rewardsdistribution();

        uint supplytomint = _supplyschedule.mintablesupply();
        require(supplytomint > 0, );

        
        _supplyschedule.recordmintevent(supplytomint);

        
        
        uint minterreward = _supplyschedule.minterreward();
        
        uint amounttodistribute = supplytomint.sub(minterreward);

        
        tokenstate.setbalanceof(
            address(_rewardsdistribution),
            tokenstate.balanceof(address(_rewardsdistribution)).add(amounttodistribute)
        );
        emittransfer(address(this), address(_rewardsdistribution), amounttodistribute);

        
        _rewardsdistribution.distributerewards(amounttodistribute);

        
        tokenstate.setbalanceof(msg.sender, tokenstate.balanceof(msg.sender).add(minterreward));
        emittransfer(address(this), msg.sender, minterreward);

        totalsupply = totalsupply.add(supplytomint);

        return true;
    }

    function liquidatedelinquentaccount(address account, uint susdamount)
        external
        systemactive
        optionalproxy
        returns (bool)
    {
        (uint totalredeemed, uint amountliquidated) = issuer().liquidatedelinquentaccount(
            account,
            susdamount,
            messagesender
        );

        emitaccountliquidated(account, totalredeemed, amountliquidated, messagesender);

        
        
        return _transferbyproxy(account, messagesender, totalredeemed);
    }

    

    modifier onlyexchanger() {
        require(msg.sender == address(exchanger()), );
        _;
    }

    modifier systemactive() {
        systemstatus().requiresystemactive();
        _;
    }

    modifier issuanceactive() {
        systemstatus().requireissuanceactive();
        _;
    }

    modifier exchangeactive(bytes32 src, bytes32 dest) {
        systemstatus().requireexchangeactive();

        systemstatus().requiresynthsactive(src, dest);

        require(!exchangerates().rateisstale(src), );
        require(!exchangerates().rateisstale(dest), );

        _;
    }

    

    event synthexchange(
        address indexed account,
        bytes32 fromcurrencykey,
        uint256 fromamount,
        bytes32 tocurrencykey,
        uint256 toamount,
        address toaddress
    );
    bytes32 internal constant synthexchange_sig = keccak256(
        
    );

    function emitsynthexchange(
        address account,
        bytes32 fromcurrencykey,
        uint256 fromamount,
        bytes32 tocurrencykey,
        uint256 toamount,
        address toaddress
    ) external onlyexchanger {
        proxy._emit(
            abi.encode(fromcurrencykey, fromamount, tocurrencykey, toamount, toaddress),
            2,
            synthexchange_sig,
            addresstobytes32(account),
            0,
            0
        );
    }

    event exchangereclaim(address indexed account, bytes32 currencykey, uint amount);
    bytes32 internal constant exchangereclaim_sig = keccak256();

    function emitexchangereclaim(
        address account,
        bytes32 currencykey,
        uint256 amount
    ) external onlyexchanger {
        proxy._emit(abi.encode(currencykey, amount), 2, exchangereclaim_sig, addresstobytes32(account), 0, 0);
    }

    event exchangerebate(address indexed account, bytes32 currencykey, uint amount);
    bytes32 internal constant exchangerebate_sig = keccak256();

    function emitexchangerebate(
        address account,
        bytes32 currencykey,
        uint256 amount
    ) external onlyexchanger {
        proxy._emit(abi.encode(currencykey, amount), 2, exchangerebate_sig, addresstobytes32(account), 0, 0);
    }

    event accountliquidated(address indexed account, uint snxredeemed, uint amountliquidated, address liquidator);
    bytes32 internal constant accountliquidated_sig = keccak256();

    function emitaccountliquidated(
        address account,
        uint256 snxredeemed,
        uint256 amountliquidated,
        address liquidator
    ) internal {
        proxy._emit(
            abi.encode(snxredeemed, amountliquidated, liquidator),
            2,
            accountliquidated_sig,
            addresstobytes32(account),
            0,
            0
        );
    }
}
