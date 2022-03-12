pragma solidity ^0.5.16;

import ;
import ;


contract usingreadproxy {
    iaddressresolver public resolver;

    constructor(iaddressresolver _resolver) public {
        resolver = _resolver;
    }

    function run(bytes32 currencykey) external view returns (uint) {
        iexchangerates exrates = iexchangerates(resolver.getaddress());
        require(address(exrates) != address(0), );
        return exrates.rateforcurrency(currencykey);
    }
}
