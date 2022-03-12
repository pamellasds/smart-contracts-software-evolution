pragma solidity 0.5.12;
pragma experimental abiencoderv2;

import ;

import {jug} from ;
import {vat} from ;


contract hevm {
    function warp(uint256) public;
}

contract vatlike {
    function ilks(bytes32) public view returns (vat.ilk memory);
    function urns(bytes32,address) public view returns (vat.urn memory);
}

contract jugtest is dstest {
    hevm hevm;
    jug jug;
    vat  vat;

    function rad(uint wad_) internal pure returns (uint) {
        return wad_ * 10 ** 27;
    }
    function wad(uint rad_) internal pure returns (uint) {
        return rad_ / 10 ** 27;
    }
    function rho(bytes32 ilk) internal view returns (uint) {
        (uint duty, uint rho_) = jug.ilks(ilk); duty;
        return rho_;
    }
    function rate(bytes32 ilk) internal view returns (uint) {
        vat.ilk memory i = vatlike(address(vat)).ilks(ilk);
        return i.rate;
    }
    function line(bytes32 ilk) internal view returns (uint) {
        vat.ilk memory i = vatlike(address(vat)).ilks(ilk);
        return i.line;
    }

    address ali = address(bytes20());

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(604411200);

        vat  = new vat();
        jug = new jug(address(vat));
        vat.rely(address(jug));
        vat.init();

        draw(, 100 ether);
    }
    function draw(bytes32 ilk, uint dai) internal {
        vat.file(, vat.line() + rad(dai));
        vat.file(ilk, , line(ilk) + rad(dai));
        vat.file(ilk, , 10 ** 27 * 10000 ether);
        address self = address(this);
        vat.slip(ilk, self,  10 ** 27 * 1 ether);
        vat.frob(ilk, self, self, self, int(1 ether), int(dai));
    }

    function test_drip_setup() public {
        hevm.warp(0);
        asserteq(uint(now), 0);
        hevm.warp(1);
        asserteq(uint(now), 1);
        hevm.warp(2);
        asserteq(uint(now), 2);
        vat.ilk memory i = vatlike(address(vat)).ilks();
        asserteq(i.art, 100 ether);
    }
    function test_drip_updates_rho() public {
        jug.init();
        asserteq(rho(), now);

        jug.file(, , 10 ** 27);
        jug.drip();
        asserteq(rho(), now);
        hevm.warp(now + 1);
        asserteq(rho(), now  1);
        jug.drip();
        asserteq(rho(), now);
        hevm.warp(now + 1 days);
        jug.drip();
        asserteq(rho(), now);
    }
    function test_drip_file() public {
        jug.init();
        jug.file(, , 10 ** 27);
        jug.drip();
        jug.file(, , 1000000564701133626865910626);  
    }
    function test_drip_0d() public {
        jug.init();
        jug.file(, , 1000000564701133626865910626);  
        asserteq(vat.dai(ali), rad(0 ether));
        jug.drip();
        asserteq(vat.dai(ali), rad(0 ether));
    }
    function test_drip_1d() public {
        jug.init();
        jug.file(, ali);

        jug.file(, , 1000000564701133626865910626);  
        hevm.warp(now + 1 days);
        asserteq(wad(vat.dai(ali)), 0 ether);
        jug.drip();
        asserteq(wad(vat.dai(ali)), 5 ether);
    }
    function test_drip_2d() public {
        jug.init();
        jug.file(, ali);
        jug.file(, , 1000000564701133626865910626);  

        hevm.warp(now + 2 days);
        asserteq(wad(vat.dai(ali)), 0 ether);
        jug.drip();
        asserteq(wad(vat.dai(ali)), 10.25 ether);
    }
    function test_drip_3d() public {
        jug.init();
        jug.file(, ali);

        jug.file(, , 1000000564701133626865910626);  
        hevm.warp(now + 3 days);
        asserteq(wad(vat.dai(ali)), 0 ether);
        jug.drip();
        asserteq(wad(vat.dai(ali)), 15.7625 ether);
    }
    function test_drip_negative_3d() public {
        jug.init();
        jug.file(, ali);

        jug.file(, , 999999706969857929985428567);  
        hevm.warp(now + 3 days);
        asserteq(wad(vat.dai(address(this))), 100 ether);
        vat.move(address(this), ali, rad(100 ether));
        asserteq(wad(vat.dai(ali)), 100 ether);
        jug.drip();
        asserteq(wad(vat.dai(ali)), 92.6859375 ether);
    }

    function test_drip_multi() public {
        jug.init();
        jug.file(, ali);

        jug.file(, , 1000000564701133626865910626);  
        hevm.warp(now + 1 days);
        jug.drip();
        asserteq(wad(vat.dai(ali)), 5 ether);
        jug.file(, , 1000001103127689513476993127);  
        hevm.warp(now + 1 days);
        jug.drip();
        asserteq(wad(vat.dai(ali)),  15.5 ether);
        asserteq(wad(vat.debt()),     115.5 ether);
        asserteq(rate() / 10 ** 9, 1.155 ether);
    }
    function test_drip_base() public {
        vat.init();
        draw(, 100 ether);

        jug.init();
        jug.init();
        jug.file(, ali);

        jug.file(, , 1050000000000000000000000000);  
        jug.file(, , 1000000000000000000000000000);  
        jug.file(,  uint(50000000000000000000000000)); 
        hevm.warp(now + 1);
        jug.drip();
        asserteq(wad(vat.dai(ali)), 10 ether);
    }
    function test_file_duty() public {
        jug.init();
        hevm.warp(now + 1);
        jug.drip();
        jug.file(, , 1);
    }
    function testfail_file_duty() public {
        jug.init();
        hevm.warp(now + 1);
        jug.file(, , 1);
    }
}
