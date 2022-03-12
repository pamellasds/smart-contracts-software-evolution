pragma solidity ^0.4.23;


import ;


contract payablesd is selfdestructible {

    constructor(address _owner)
        selfdestructible(_owner) public {}

    function () public payable {}
}
