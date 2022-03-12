pragma solidity ^0.4.23;


interface voting {    
    function startpoll(uint _numoptions, uint _revealedquorum, uint _commitduration, uint _revealduration) external;
    function commitvote(uint _pollid, bytes32 _secrethash) external;
    function revealvote(uint _pollid, uint _voteoption, uint _salt) external;
    function winner(uint _pollid) view external returns (uint);
}