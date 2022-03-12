pragma solidity 0.4.25;

import ;
import ;


contract mixinresolver is owned {
    addressresolver public resolver;

    constructor(address _owner, address _resolver) public owned(_owner) {
        resolver = addressresolver(_resolver);
    }

    

    function setresolver(addressresolver _resolver) public onlyowner {
        resolver = _resolver;
    }
}
