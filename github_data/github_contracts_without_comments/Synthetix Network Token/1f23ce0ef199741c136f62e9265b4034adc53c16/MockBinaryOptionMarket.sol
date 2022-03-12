pragma solidity ^0.5.16;

import ;

import ;


contract mockbinaryoptionmarket {
    using safedecimalmath for uint;

    uint public deposited;
    uint public senderprice;
    binaryoption public binaryoption;

    function setdeposited(uint newdeposited) external {
        deposited = newdeposited;
    }

    function setsenderprice(uint newprice) external {
        senderprice = newprice;
    }

    function exercisabledeposits() external view returns (uint) {
        return deposited;
    }

    function senderpriceandexercisabledeposits() external view returns (uint price, uint _deposited) {
        return (senderprice, deposited);
    }

    function deployoption(address initialbidder, uint initialbid) external {
        binaryoption = new binaryoption(initialbidder, initialbid);
    }

    function claimoptions() external returns (uint) {
        return binaryoption.claim(msg.sender, senderprice, deposited);
    }

    function exerciseoptions() external {
        deposited = binaryoption.balanceof(msg.sender);
        binaryoption.exercise(msg.sender);
    }

    function bid(address bidder, uint newbid) external {
        binaryoption.bid(bidder, newbid);
        deposited += newbid.dividedecimalround(senderprice);
    }

    function refund(address bidder, uint newrefund) external {
        binaryoption.refund(bidder, newrefund);
        deposited = newrefund.dividedecimalround(senderprice);
    }

    function expireoption(address payable beneficiary) external {
        binaryoption.expire(beneficiary);
    }

    function requireactiveandunpaused() external pure {
        return;
    }

    event newoption(binaryoption newaddress);
}
