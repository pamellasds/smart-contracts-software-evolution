pragma solidity 0.4.25;

import ;
import ;
import ;
import ;


contract purgeablesynth is synth {
    using safedecimalmath for uint;

    
    uint public maxsupplytopurgeinusd = 100000 * safedecimalmath.unit(); 

    

    constructor(
        address _proxy,
        tokenstate _tokenstate,
        string _tokenname,
        string _tokensymbol,
        address _owner,
        bytes32 _currencykey,
        uint _totalsupply,
        address _resolver
    ) public synth(_proxy, _tokenstate, _tokenname, _tokensymbol, _owner, _currencykey, _totalsupply, _resolver) {}

    

    function exchangerates() internal view returns (iexchangerates) {
        require(resolver.getaddress() != address(0), );
        return iexchangerates(resolver.getaddress());
    }

    

    
    function purge(address[] addresses) external optionalproxy_onlyowner {
        iexchangerates exrates = exchangerates();

        uint maxsupplytopurge = exrates.effectivevalue(, maxsupplytopurgeinusd, currencykey);

        
        require(
            totalsupply <= maxsupplytopurge || exrates.rateisfrozen(currencykey),
            
        );

        for (uint i = 0; i < addresses.length; i++) {
            address holder = addresses[i];

            uint amountheld = balanceof(holder);

            if (amountheld > 0) {
                exchanger().exchange(holder, currencykey, amountheld, , holder);
                emitpurged(holder, amountheld);
            }
        }
    }

    
    event purged(address indexed account, uint value);
    bytes32 private constant purged_sig = keccak256();

    function emitpurged(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, purged_sig, bytes32(account), 0, 0);
    }
}
