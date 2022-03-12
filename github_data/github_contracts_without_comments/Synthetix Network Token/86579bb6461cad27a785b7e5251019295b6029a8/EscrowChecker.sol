pragma solidity ^0.5.16;


interface isynthetixescrow {
    function numvestingentries(address account) external view returns (uint);

    function getvestingscheduleentry(address account, uint index) external view returns (uint[2] memory);
}



contract escrowchecker {
    isynthetixescrow public synthetix_escrow;

    constructor(isynthetixescrow _esc) public {
        synthetix_escrow = _esc;
    }

    function checkaccountschedule(address account) public view returns (uint[16] memory) {
        uint[16] memory _result;
        uint schedules = synthetix_escrow.numvestingentries(account);
        for (uint i = 0; i < schedules; i++) {
            uint[2] memory pair = synthetix_escrow.getvestingscheduleentry(account, i);
            _result[i * 2] = pair[0];
            _result[i * 2 + 1] = pair[1];
        }
        return _result;
    }
}
