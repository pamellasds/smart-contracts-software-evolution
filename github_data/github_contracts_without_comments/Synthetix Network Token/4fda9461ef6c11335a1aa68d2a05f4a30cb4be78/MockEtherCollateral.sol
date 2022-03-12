pragma solidity ^0.5.16;

import ;


contract mockethercollateral {
    using safemath for uint;
    using safedecimalmath for uint;

    uint public totalissuedsynths;

    constructor() public {}

    
    function openloan(uint amount) external {
        
        totalissuedsynths = totalissuedsynths.add(amount);
    }

    function closeloan(uint amount) external {
        
        totalissuedsynths = totalissuedsynths.sub(amount);
    }
}
