pragma solidity 0.4.25;

import ;

library math {

    using safemath for uint;
    using safedecimalmath for uint;

    
    function powdecimal(uint x, uint n)
        internal
        pure
        returns (uint)
    {
        

        uint result = safedecimalmath.unit();
        while (n > 0) {
            if (n % 2 != 0) {
                result = result.multiplydecimal(x);
            }
            x = x.multiplydecimal(x);
            n /= 2;
        }
        return result;
    }
}
    