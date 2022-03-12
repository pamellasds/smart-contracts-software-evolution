


pragma solidity 0.4.25;

import ;
import ;
import ;


contract purgeablesynth is synth {

    using safedecimalmath for uint;

    
    uint public maxsupplytopurgeinusd = 100000 * safedecimalmath.unit(); 

    
    exchangerates public exchangerates;

    

    constructor(address _proxy, tokenstate _tokenstate, synthetix _synthetix, ifeepool _feepool,
        string _tokenname, string _tokensymbol, address _owner, bytes4 _currencykey, exchangerates _exchangerates
    )
        synth(_proxy, _tokenstate, _synthetix, _feepool, _tokenname, _tokensymbol, _owner, _currencykey)
        public
    {
        exchangerates = _exchangerates;
    }

    

    
    function purge(address[] addresses)
        external
        optionalproxy_onlyowner
    {
        uint maxsupplytopurge = exchangerates.effectivevalue(, maxsupplytopurgeinusd, currencykey);

        
        require(
            totalsupply <= maxsupplytopurge || exchangerates.rateisfrozen(currencykey),
            
        );

        for (uint8 i = 0; i < addresses.length; i++) {
            address holder = addresses[i];

            uint amountheld = balanceof(holder);

            if (amountheld > 0) {
                synthetix.synthinitiatedexchange(holder, currencykey, amountheld, , holder);
                emitpurged(holder, amountheld);
            }

        }

    }

    

    function setexchangerates(exchangerates _exchangerates)
        external
        optionalproxy_onlyowner
    {
        exchangerates = _exchangerates;
    }

    

    event purged(address indexed account, uint value);
    bytes32 constant purged_sig = keccak256();
    function emitpurged(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, purged_sig, bytes32(account), 0, 0);
    }
}
