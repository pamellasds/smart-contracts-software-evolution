pragma solidity ^0.4.1;

import * as source from ;

contract badwallet {
    uint16 extra_work = 0; 
    uint16 public out_i;
    address wallet;

    function badwallet() {
    }

    function get_out_i() returns (uint16 a) {
        return out_i;
    }

    function set_extra_work(uint16 _extra_work) {
        extra_work = _extra_work;
    }

    function get_extra_work() returns (uint16 a) {
        return extra_work;
    }

    function deploy_contract(address _golemfactory, uint256 _fundingstartblock,
                             uint256 _fundingendblock)
        returns (address a) {

        wallet = new source.golemnetworktoken(_golemfactory, _golemfactory,
                                              _fundingstartblock,
                                              _fundingendblock);
        return wallet;
    }

    function finalize(address _crowdfundingcontract) {
        source.golemnetworktoken(_crowdfundingcontract).finalize();
    }

    
    function() payable {
        for (uint16 i = 1; i <= extra_work; i++) {
            out_i = i;
        }
    }
}
