pragma solidity ^0.5.16;

import ;


import ;


contract mixinsystemsettings is mixinresolver {
    bytes32 internal constant setting_contract_name = ;

    bytes32 internal constant setting_waiting_period_secs = ;
    bytes32 internal constant setting_price_deviation_threshold_factor = ;
    bytes32 internal constant setting_issuance_ratio = ;
    bytes32 internal constant setting_fee_period_duration = ;
    bytes32 internal constant setting_target_threshold = ;
    bytes32 internal constant setting_liquidation_delay = ;
    bytes32 internal constant setting_liquidation_ratio = ;
    bytes32 internal constant setting_liquidation_penalty = ;
    bytes32 internal constant setting_rate_stale_period = ;
    bytes32 internal constant setting_exchange_fee_rate = ;
    bytes32 internal constant setting_minimum_stake_time = ;

    bytes32 private constant contract_flexiblestorage = ;

    constructor() internal {
        appendtoaddresscache(contract_flexiblestorage);
    }

    function flexiblestorage() internal view returns (iflexiblestorage) {
        return iflexiblestorage(requireandgetaddress(contract_flexiblestorage, ));
    }

    function getwaitingperiodsecs() internal view returns (uint) {
        return flexiblestorage().getuintvalue(setting_contract_name, setting_waiting_period_secs);
    }

    function getpricedeviationthresholdfactor() internal view returns (uint) {
        return flexiblestorage().getuintvalue(setting_contract_name, setting_price_deviation_threshold_factor);
    }

    function getissuanceratio() internal view returns (uint) {
        
        return flexiblestorage().getuintvalue(setting_contract_name, setting_issuance_ratio);
    }

    function getfeeperiodduration() internal view returns (uint) {
        
        return flexiblestorage().getuintvalue(setting_contract_name, setting_fee_period_duration);
    }

    function gettargetthreshold() internal view returns (uint) {
        
        return flexiblestorage().getuintvalue(setting_contract_name, setting_target_threshold);
    }

    function getliquidationdelay() internal view returns (uint) {
        return flexiblestorage().getuintvalue(setting_contract_name, setting_liquidation_delay);
    }

    function getliquidationratio() internal view returns (uint) {
        return flexiblestorage().getuintvalue(setting_contract_name, setting_liquidation_ratio);
    }

    function getliquidationpenalty() internal view returns (uint) {
        return flexiblestorage().getuintvalue(setting_contract_name, setting_liquidation_penalty);
    }

    function getratestaleperiod() internal view returns (uint) {
        return flexiblestorage().getuintvalue(setting_contract_name, setting_rate_stale_period);
    }

    function getexchangefeerate(bytes32 currencykey) internal view returns (uint) {
        return
            flexiblestorage().getuintvalue(
                setting_contract_name,
                keccak256(abi.encodepacked(setting_exchange_fee_rate, currencykey))
            );
    }

    function getminimumstaketime() internal view returns (uint) {
        return flexiblestorage().getuintvalue(setting_contract_name, setting_minimum_stake_time);
    }
}
