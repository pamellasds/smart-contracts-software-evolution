pragma solidity >=0.5.0;
pragma experimental abiencoderv2;

import ;

import {jug} from ;
import {vat} from ;


contract hevm {
    function warp(uint256) public;
}

contract vatlike {
    function ilks(bytes32) public view returns (vat.ilk memory);
    function urns(bytes32,bytes32) public view returns (vat.urn memory);
}

contract jugtest is dstest {
    hevm hevm;
    jug drip;
    vat  vat;

    function rad(uint wad_) internal pure returns (uint) {
        return wad_ * 10 ** 27;
    }
    function wad(uint rad_) internal pure returns (uint) {
        return rad_ / 10 ** 27;
    }
    function rho(bytes32 ilk) internal view returns (uint) {
        (uint tax, uint48 rho_) = drip.ilks(ilk); tax;
        return uint(rho_);
    }
    function rate(bytes32 ilk) internal view returns (uint) {
        vat.ilk memory i = vatlike(address(vat)).ilks(ilk);
        return i.rate;
    }

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(0);

        vat  = new vat();
        drip = new jug(address(vat));
        vat.rely(address(drip));
        vat.init();

        draw(, 100 ether);
    }
    function draw(bytes32 ilk, uint dai) internal {
        vat.file(, rad(dai));
        vat.file(ilk, , rad(dai));
        vat.file(ilk, , 10 ** 27 * 10000 ether);
        bytes32 self = bytes32(bytes20(address(this)));
        vat.slip(ilk, self,  10 ** 27 * 1 ether);
        vat.frob(ilk, self, self, self, int(1 ether), int(dai));
    }

    function test_drip_setup() public {
        asserteq(uint(now), 0);
        hevm.warp(1);
        asserteq(uint(now), 1);
        hevm.warp(2);
        asserteq(uint(now), 2);
        vat.ilk memory i = vatlike(address(vat)).ilks();
        asserteq(i.art, 100 ether);
    }
    function test_drip_updates_rho() public {
        drip.init();
        asserteq(rho(), 0);

        drip.file(, , 10 ** 27);
        drip.drip();
        asserteq(rho(), 0);
        hevm.warp(1);
        asserteq(rho(), 0);
        drip.drip();
        asserteq(rho(), 1);
        hevm.warp(1 days);
        drip.drip();
        asserteq(rho(), 1 days);
    }
    function test_drip_file() public {
        drip.init();
        drip.file(, , 10 ** 27);
        hevm.warp(1);
        drip.drip();
        drip.file(, , 1000000564701133626865910626);  
    }
    function test_drip_0d() public {
        drip.init();
        drip.file(, , 1000000564701133626865910626);  
        asserteq(vat.dai(), rad(0 ether));
        drip.drip();
        asserteq(vat.dai(), rad(0 ether));
    }
    function test_drip_1d() public {
        drip.init();
        drip.file(, );

        drip.file(, , 1000000564701133626865910626);  
        hevm.warp(1 days);
        asserteq(wad(vat.dai()), 0 ether);
        drip.drip();
        asserteq(wad(vat.dai()), 5 ether);
    }
    function test_drip_2d() public {
        drip.init();
        drip.file(, );
        drip.file(, , 1000000564701133626865910626);  

        hevm.warp(2 days);
        asserteq(wad(vat.dai()), 0 ether);
        drip.drip();
        asserteq(wad(vat.dai()), 10.25 ether);
    }
    function test_drip_3d() public {
        drip.init();
        drip.file(, );

        drip.file(, , 1000000564701133626865910626);  
        hevm.warp(3 days);
        asserteq(wad(vat.dai()), 0 ether);
        drip.drip();
        asserteq(wad(vat.dai()), 15.7625 ether);
    }
    function test_drip_multi() public {
        drip.init();
        drip.file(, );

        drip.file(, , 1000000564701133626865910626);  
        hevm.warp(1 days);
        drip.drip();
        asserteq(wad(vat.dai()), 5 ether);
        drip.file(, , 1000001103127689513476993127);  
        hevm.warp(2 days);
        drip.drip();
        asserteq(wad(vat.dai()),  15.5 ether);
        asserteq(wad(vat.debt()),     115.5 ether);
        asserteq(rate() / 10 ** 9, 1.155 ether);
    }
    function test_drip_repo() public {
        vat.init();
        draw(, 100 ether);

        drip.init();
        drip.init();
        drip.file(, );

        drip.file(, , 1050000000000000000000000000);  
        drip.file(, , 1000000000000000000000000000);  
        drip.file(,  uint(50000000000000000000000000)); 
        hevm.warp(1);
        drip.drip();
        asserteq(wad(vat.dai()), 10 ether);
    }
}
