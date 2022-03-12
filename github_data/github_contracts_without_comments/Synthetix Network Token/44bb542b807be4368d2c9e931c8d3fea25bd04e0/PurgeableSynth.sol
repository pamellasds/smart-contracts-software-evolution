pragma solidity ^0.5.16;


import ;


import ;


import ;



contract purgeablesynth is synth {
    using safedecimalmath for uint;

    
    uint public maxsupplytopurgeinusd = 100000 * safedecimalmath.unit(); 

    bytes32 private constant contract_exrates = ;

    

    constructor(
        address payable _proxy,
        tokenstate _tokenstate,
        string memory _tokenname,
        string memory _tokensymbol,
        address payable _owner,
        bytes32 _currencykey,
        uint _totalsupply,
        address _resolver
    ) public synth(_proxy, _tokenstate, _tokenname, _tokensymbol, _owner, _currencykey, _totalsupply, _resolver) {
        appendtoaddresscache(contract_exrates);
    }

    

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    

    
    function purge(address[] calldata addresses) external optionalproxy_onlyowner {
        iexchangerates exrates = exchangerates();

        uint maxsupplytopurge = exrates.effectivevalue(, maxsupplytopurgeinusd, currencykey);

        
        require(
            totalsupply <= maxsupplytopurge || exrates.rateisfrozen(currencykey),
            
        );

        for (uint i = 0; i < addresses.length; i++) {
            address holder = addresses[i];

            uint amountheld = tokenstate.balanceof(holder);

            if (amountheld > 0) {
                exchanger().exchange(holder, currencykey, amountheld, , holder);
                emitpurged(holder, amountheld);
            }
        }
    }

    
    event purged(address indexed account, uint value);
    bytes32 private constant purged_sig = keccak256();

    function emitpurged(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, purged_sig, addresstobytes32(account), 0, 0);
    }
}
