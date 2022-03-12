pragma solidity ^0.4.20;

import ;

contract fakecourt {
    ethernomin public nomin;

    mapping(uint => bool) public motionconfirming;
    mapping(uint => bool) public motionpasses;
    mapping(address => uint) public targetmotionid;

    function setnomin(ethernomin newnomin)
        public
    {
        nomin = newnomin;
    }

    function setconfirming(uint motionid, bool status)
        public
    {
        motionconfirming[motionid] = status;
    }

    function setvotepasses(uint motionid, bool status)
        public
    {
        motionpasses[motionid] = status;
    }

    function settargetmotionid(address target, uint motionid)
        public
    {
        targetmotionid[target] = motionid;
    }

    function confiscatebalance(address target)
        public
    {
        nomin.confiscatebalance(target);
    }
}
