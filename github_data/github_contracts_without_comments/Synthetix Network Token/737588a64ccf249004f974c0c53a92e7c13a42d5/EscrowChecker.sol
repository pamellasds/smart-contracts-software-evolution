pragma solidity 0.4.25;

contract synthetixescrow {
    function numvestingentries(address account) public returns (uint);
    function getvestingscheduleentry(address account, uint index) public returns (uint[2]);
}

contract escrowchecker {
    synthetixescrow public synthetix_escrow;
    function escrowchecker(synthetixescrow _esc) public {
        synthetix_escrow = _esc;
    }

    function checkaccountschedule(address account)
        public
        view
        returns (uint[16])
    {
        uint[16] memory _result;
        uint schedules = synthetix_escrow.numvestingentries(account);
        for (uint i = 0; i < schedules; i++) {
            uint[2] memory pair = synthetix_escrow.getvestingscheduleentry(account, i);
            _result[i*2] = pair[0];
            _result[i*2 + 1] = pair[1];
        }
        return _result;
    }
}
