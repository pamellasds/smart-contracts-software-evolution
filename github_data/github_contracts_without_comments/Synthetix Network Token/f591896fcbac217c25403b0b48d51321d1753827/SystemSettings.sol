pragma solidity ^0.5.16;


import ;
import ;
import ;
import ;


import ;


contract systemsettings is owned, mixinresolver, mixinsystemsettings, isystemsettings {
    using safemath for uint;
    using safedecimalmath for uint;

    
    uint public constant max_issuance_ratio = 1e18;

    
    uint public constant min_fee_period_duration = 1 days;
    uint public constant max_fee_period_duration = 60 days;

    uint public constant max_target_threshold = 50;

    uint public constant max_liquidation_ratio = 1e18; 

    uint public constant max_liquidation_penalty = 1e18 / 4; 

    uint public constant ratio_from_target_buffer = 2e18; 

    uint public constant max_liquidation_delay = 30 days;
    uint public constant min_liquidation_delay = 1 days;

    
    uint public constant max_exchange_fee_rate = 1e18 / 10;

    
    uint public constant max_minimum_stake_time = 1 weeks;

    bytes32[24] private addressestocache = [bytes32(0)];

    constructor(address _owner, address _resolver)
        public
        owned(_owner)
        mixinresolver(_resolver, addressestocache)
        mixinsystemsettings()
    {}

    

    
    
    
    function waitingperiodsecs() external view returns (uint) {
        return getwaitingperiodsecs();
    }

    
    
    
    function pricedeviationthresholdfactor() external view returns (uint) {
        return getpricedeviationthresholdfactor();
    }

    
    
    function issuanceratio() external view returns (uint) {
        return getissuanceratio();
    }

    
    
    
    
    function feeperiodduration() external view returns (uint) {
        return getfeeperiodduration();
    }

    
    function targetthreshold() external view returns (uint) {
        return gettargetthreshold();
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

    
    function ratestaleperiod() external view returns (uint) {
        return getratestaleperiod();
    }

    function exchangefeerate(bytes32 currencykey) external view returns (uint) {
        return getexchangefeerate(currencykey);
    }

    function minimumstaketime() external view returns (uint) {
        return getminimumstaketime();
    }

    

    function setwaitingperiodsecs(uint _waitingperiodsecs) external onlyowner {
        flexiblestorage().setuintvalue(setting_contract_name, setting_waiting_period_secs, _waitingperiodsecs);
        emit waitingperiodsecsupdated(_waitingperiodsecs);
    }

    function setpricedeviationthresholdfactor(uint _pricedeviationthresholdfactor) external onlyowner {
        flexiblestorage().setuintvalue(
            setting_contract_name,
            setting_price_deviation_threshold_factor,
            _pricedeviationthresholdfactor
        );
        emit pricedeviationthresholdupdated(_pricedeviationthresholdfactor);
    }

    function setissuanceratio(uint _issuanceratio) external onlyowner {
        require(_issuanceratio <= max_issuance_ratio, );
        flexiblestorage().setuintvalue(setting_contract_name, setting_issuance_ratio, _issuanceratio);
        emit issuanceratioupdated(_issuanceratio);
    }

    function setfeeperiodduration(uint _feeperiodduration) external onlyowner {
        require(_feeperiodduration >= min_fee_period_duration, );
        require(_feeperiodduration <= max_fee_period_duration, );

        flexiblestorage().setuintvalue(setting_contract_name, setting_fee_period_duration, _feeperiodduration);

        emit feeperioddurationupdated(_feeperiodduration);
    }

    function settargetthreshold(uint _percent) external onlyowner {
        require(_percent <= max_target_threshold, );

        uint _targetthreshold = _percent.mul(safedecimalmath.unit()).div(100);

        flexiblestorage().setuintvalue(setting_contract_name, setting_target_threshold, _targetthreshold);

        emit targetthresholdupdated(_targetthreshold);
    }

    function setliquidationdelay(uint time) external onlyowner {
        require(time <= max_liquidation_delay, );
        require(time >= min_liquidation_delay, );

        flexiblestorage().setuintvalue(setting_contract_name, setting_liquidation_delay, time);

        emit liquidationdelayupdated(time);
    }

    
    
    function setliquidationratio(uint _liquidationratio) external onlyowner {
        require(
            _liquidationratio <= max_liquidation_ratio.dividedecimal(safedecimalmath.unit().add(getliquidationpenalty())),
            
        );

        
        
        uint min_liquidation_ratio = getissuanceratio().multiplydecimal(ratio_from_target_buffer);
        require(_liquidationratio >= min_liquidation_ratio, );

        flexiblestorage().setuintvalue(setting_contract_name, setting_liquidation_ratio, _liquidationratio);

        emit liquidationratioupdated(_liquidationratio);
    }

    function setliquidationpenalty(uint penalty) external onlyowner {
        require(penalty <= max_liquidation_penalty, );

        flexiblestorage().setuintvalue(setting_contract_name, setting_liquidation_penalty, penalty);

        emit liquidationpenaltyupdated(penalty);
    }

    function setratestaleperiod(uint period) external onlyowner {
        flexiblestorage().setuintvalue(setting_contract_name, setting_rate_stale_period, period);

        emit ratestaleperiodupdated(period);
    }

    function setexchangefeerateforsynths(bytes32[] calldata synthkeys, uint256[] calldata exchangefeerates)
        external
        onlyowner
    {
        require(synthkeys.length == exchangefeerates.length, );
        for (uint i = 0; i < synthkeys.length; i++) {
            require(exchangefeerates[i] <= max_exchange_fee_rate, );
            flexiblestorage().setuintvalue(
                setting_contract_name,
                keccak256(abi.encodepacked(setting_exchange_fee_rate, synthkeys[i])),
                exchangefeerates[i]
            );
            emit exchangefeeupdated(synthkeys[i], exchangefeerates[i]);
        }
    }

    function setminimumstaketime(uint _seconds) external onlyowner {
        require(_seconds <= max_minimum_stake_time, );
        flexiblestorage().setuintvalue(setting_contract_name, setting_minimum_stake_time, _seconds);
        emit minimumstaketimeupdated(_seconds);
    }

    
    event waitingperiodsecsupdated(uint waitingperiodsecs);
    event pricedeviationthresholdupdated(uint threshold);
    event issuanceratioupdated(uint newratio);
    event feeperioddurationupdated(uint newfeeperiodduration);
    event targetthresholdupdated(uint newtargetthreshold);
    event liquidationdelayupdated(uint newdelay);
    event liquidationratioupdated(uint newratio);
    event liquidationpenaltyupdated(uint newpenalty);
    event ratestaleperiodupdated(uint ratestaleperiod);
    event exchangefeeupdated(bytes32 synthkey, uint newexchangefeerate);
    event minimumstaketimeupdated(uint minimumstaketime);
}
