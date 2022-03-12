pragma solidity 0.4.25;

import ;


contract testablepausable is pausable {

    uint public somevalue;

    constructor(address _owner)
        pausable(_owner)
        public
    {}

    function setsomevalue(uint _value)
        external
        notpaused
    {
        somevalue = _value;
    }

}

