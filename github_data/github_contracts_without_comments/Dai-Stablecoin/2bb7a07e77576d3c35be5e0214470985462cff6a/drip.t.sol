pragma solidity ^0.4.24;

import ;

import ;
import ;

contract warpdrip is drip {
    constructor(address vat_) public drip(vat_) {}
    uint48 _era; function warp(uint48 era_) public { _era = era_; }
    function era() public view returns (uint48) { return _era; }
}

contract driptest is dstest {
    vat      vat;
    warpdrip drip;

    function rad(uint wad_) internal pure returns (uint) {
        return wad_ * 10 ** 27;
    }
    function wad(uint rad_) internal pure returns (uint) {
        return rad_ / 10 ** 27;
    }
    function rho(bytes32 ilk) internal view returns (uint) {
        (bytes32 vow, uint tax, uint48 rho_) = drip.ilks(ilk); vow; tax;
        return uint(rho_);
    }
    function setup() public {
        vat  = new vat();
        drip = new warpdrip(vat);
        vat.init();
        vat.tune(, , , , 0, 100 ether);
    }
    function test_drip_setup() public {
        asserteq(uint(drip.era()), 0);
        (uint rate, uint art) = vat.ilks(); rate;
        asserteq(art, 100 ether);
    }
    function test_drip_updates_rho() public {
        drip.file(, , 10 ** 27);
        drip.drip();
        asserteq(rho(), 0);
        drip.warp(1);
        asserteq(rho(), 0);
        drip.drip();
        asserteq(rho(), 1);
        drip.warp(1 days);
        drip.drip();
        asserteq(rho(), 1 days);
    }
    function test_drip_file() public {
        drip.file(, , 10 ** 27);
        drip.warp(1);
        drip.drip();
        drip.file(, , 1000000564701133626865910626);  
    }
    function test_drip_0d() public {
        drip.file(, , 1000000564701133626865910626);  
        asserteq(vat.dai(), rad(0 ether));
        drip.drip();
        asserteq(vat.dai(), rad(0 ether));
    }
    function test_drip_1d() public {
        drip.file(, , 1000000564701133626865910626);  
        drip.warp(1 days);
        asserteq(wad(vat.dai()), 0 ether);
        drip.drip();
        asserteq(wad(vat.dai()), 5 ether);
    }
    function test_drip_2d() public {
        drip.file(, , 1000000564701133626865910626);  
        drip.warp(2 days);
        asserteq(wad(vat.dai()), 0 ether);
        drip.drip();
        asserteq(wad(vat.dai()), 10.25 ether);
    }
    function test_drip_3d() public {
        drip.file(, , 1000000564701133626865910626);  
        drip.warp(3 days);
        asserteq(wad(vat.dai()), 0 ether);
        drip.drip();
        asserteq(wad(vat.dai()), 15.7625 ether);
    }
}
