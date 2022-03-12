
pragma solidity 0.4.25;

import ;

contract publicmath {
    using math for uint;

    function powerdecimal(uint x, uint y)
        public
        pure
        returns (uint)
    {
        return x.powdecimal(y);
    }
}
