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



contract liquidations is owned, mixinresolver, mixinsystemsettings, iliquidations {
    using safemath for uint;
    using safedecimalmath for uint;

    struct liquidationentry {
        uint deadline;
        address caller;
    }

    

    bytes32 private constant contract_systemstatus = ;
    bytes32 private constant contract_synthetix = ;
    bytes32 private constant contract_eternalstorage_liquidations = ;
    bytes32 private constant contract_issuer = ;
    bytes32 private constant contract_exrates = ;

    bytes32[24] private addressestocache = [
        contract_systemstatus,
        contract_synthetix,
        contract_eternalstorage_liquidations,
        contract_issuer,
        contract_exrates
    ];

    

    
    bytes32 public constant liquidation_deadline = ;
    bytes32 public constant liquidation_caller = ;

    constructor(address _owner, address _resolver)
        public
        owned(_owner)
        mixinresolver(_resolver, addressestocache)
        mixinsystemsettings()
    {}

    
    function synthetix() internal view returns (isynthetix) {
        return isynthetix(requireandgetaddress(contract_synthetix, ));
    }

    function systemstatus() internal view returns (isystemstatus) {
        return isystemstatus(requireandgetaddress(contract_systemstatus, ));
    }

    function issuer() internal view returns (iissuer) {
        return iissuer(requireandgetaddress(contract_issuer, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    
    function eternalstorageliquidations() internal view returns (eternalstorage) {
        return
            eternalstorage(
                requireandgetaddress(contract_eternalstorage_liquidations, )
            );
    }

    function issuanceratio() external view returns (uint) {
        return getissuanceratio();
    }

    function liquidationdelay() external view returns (uint) {
        return getliquidationdelay();
    }

    function liquidationratio() external view returns (uint) {
        return getliquidationratio();
    }

    function liquidationpenalty() external view returns (uint) {
        return getliquidationpenalty();
    }

    function liquidationcollateralratio() external view returns (uint) {
        return safedecimalmath.unit().dividedecimalround(getliquidationratio());
    }

    function getliquidationdeadlineforaccount(address account) external view returns (uint) {
        liquidationentry memory liquidation = _getliquidationentryforaccount(account);
        return liquidation.deadline;
    }

    function isopenforliquidation(address account) external view returns (bool) {
        uint accountcollateralisationratio = synthetix().collateralisationratio(account);

        
        
        if (accountcollateralisationratio <= getissuanceratio()) {
            return false;
        }

        liquidationentry memory liquidation = _getliquidationentryforaccount(account);

        
        if (_deadlinepassed(liquidation.deadline)) {
            return true;
        }
        return false;
    }

    function isliquidationdeadlinepassed(address account) external view returns (bool) {
        liquidationentry memory liquidation = _getliquidationentryforaccount(account);
        return _deadlinepassed(liquidation.deadline);
    }

    function _deadlinepassed(uint deadline) internal view returns (bool) {
        
        
        return deadline > 0 && now > deadline;
    }

    
    function calculateamounttofixcollateral(uint debtbalance, uint collateral) external view returns (uint) {
        uint ratio = getissuanceratio();
        uint unit = safedecimalmath.unit();

        uint dividend = debtbalance.sub(collateral.multiplydecimal(ratio));
        uint divisor = unit.sub(unit.add(getliquidationpenalty()).multiplydecimal(ratio));

        return dividend.dividedecimal(divisor);
    }

    
    
    function _getliquidationentryforaccount(address account) internal view returns (liquidationentry memory _liquidation) {
        _liquidation.deadline = eternalstorageliquidations().getuintvalue(_getkey(liquidation_deadline, account));

        
        _liquidation.caller = address(0);
    }

    function _getkey(bytes32 _scope, address _account) internal pure returns (bytes32) {
        return keccak256(abi.encodepacked(_scope, _account));
    }

    

    
    
    function flagaccountforliquidation(address account) external ratenotinvalid() {
        systemstatus().requiresystemactive();

        require(getliquidationratio() > 0, );
        require(getliquidationdelay() > 0, );

        liquidationentry memory liquidation = _getliquidationentryforaccount(account);
        require(liquidation.deadline == 0, );

        uint accountscollateralisationratio = synthetix().collateralisationratio(account);

        
        require(
            accountscollateralisationratio >= getliquidationratio(),
            
        );

        uint deadline = now.add(getliquidationdelay());

        _storeliquidationentry(account, deadline, msg.sender);

        emit accountflaggedforliquidation(account, deadline);
    }

    
    
    function removeaccountinliquidation(address account) external onlyissuer {
        liquidationentry memory liquidation = _getliquidationentryforaccount(account);
        if (liquidation.deadline > 0) {
            _removeliquidationentry(account);
        }
    }

    
    
    
    function checkandremoveaccountinliquidation(address account) external ratenotinvalid() {
        systemstatus().requiresystemactive();

        liquidationentry memory liquidation = _getliquidationentryforaccount(account);

        require(liquidation.deadline > 0, );

        uint accountscollateralisationratio = synthetix().collateralisationratio(account);

        
        if (accountscollateralisationratio <= getissuanceratio()) {
            _removeliquidationentry(account);
        }
    }

    function _storeliquidationentry(
        address _account,
        uint _deadline,
        address _caller
    ) internal {
        
        eternalstorageliquidations().setuintvalue(_getkey(liquidation_deadline, _account), _deadline);
        eternalstorageliquidations().setaddressvalue(_getkey(liquidation_caller, _account), _caller);
    }

    function _removeliquidationentry(address _account) internal {
        
        eternalstorageliquidations().deleteuintvalue(_getkey(liquidation_deadline, _account));
        
        eternalstorageliquidations().deleteaddressvalue(_getkey(liquidation_caller, _account));

        emit accountremovedfromliquidation(_account, now);
    }

    
    modifier onlyissuer() {
        require(msg.sender == address(issuer()), );
        _;
    }

    modifier ratenotinvalid(bytes32 currencykey) {
        require(!exchangerates().rateisinvalid(currencykey), );
        _;
    }

    

    event accountflaggedforliquidation(address indexed account, uint deadline);
    event accountremovedfromliquidation(address indexed account, uint time);
}
