pragma solidity ^0.4.20;


import ;


contract payablesd is selfdestructible {

    function payablesd(address _owner, address _beneficiary)
        selfdestructible(_owner, _beneficiary) public {}

    function () public payable {}
}
