pragma solidity ^0.4.23;

import ;

contract fakecourt {
    nomin public nomin;

    mapping(uint => bool) public motionconfirming;
    mapping(uint => bool) public motionpasses;
    mapping(address => uint) public targetmotionid;

    function setnomin(nomin newnomin)
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

    function freezeandconfiscate(address target)
        public
    {
        nomin.freezeandconfiscate(target);
    }
}
