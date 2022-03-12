pragma solidity ^0.5.12;

import ;
import {vat} from ;
import {pot} from ;

contract hevm {
    function warp(uint256) public;
}

contract dsrtest is dstest {
    hevm hevm;

    vat vat;
    pot pot;

    address vow;
    address self;
    address potb;

    function rad(uint wad_) internal pure returns (uint) {
        return wad_ * 10 ** 27;
    }
    function wad(uint rad_) internal pure returns (uint) {
        return rad_ / 10 ** 27;
    }

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(604411200);

        vat = new vat();
        pot = new pot(address(vat));
        vat.rely(address(pot));
        self = address(this);
        potb = address(pot);

        vow = address(bytes20());
        pot.file(, vow);

        vat.suck(self, self, rad(100 ether));
        vat.hope(address(pot));
    }
    function test_save_0d() public {
        asserteq(vat.dai(self), rad(100 ether));

        pot.join(100 ether);
        asserteq(wad(vat.dai(self)),   0 ether);
        asserteq(pot.pie(self),      100 ether);

        pot.drip();

        pot.exit(100 ether);
        asserteq(wad(vat.dai(self)), 100 ether);
    }
    function test_save_1d() public {
        pot.join(100 ether);
        pot.file(, uint(1000000564701133626865910626));  
        hevm.warp(now + 1 days);
        pot.drip();
        asserteq(pot.pie(self), 100 ether);
        pot.exit(100 ether);
        asserteq(wad(vat.dai(self)), 105 ether);
    }
    function test_drip_multi() public {
        pot.join(100 ether);
        pot.file(, uint(1000000564701133626865910626));  
        hevm.warp(now + 1 days);
        pot.drip();
        asserteq(wad(vat.dai(potb)),   105 ether);
        pot.file(, uint(1000001103127689513476993127));  
        hevm.warp(now + 1 days);
        pot.drip();
        asserteq(wad(vat.sin(vow)), 15.5 ether);
        asserteq(wad(vat.dai(potb)), 115.5 ether);
        asserteq(pot.pie(),          100   ether);
        asserteq(pot.chi() / 10 ** 9, 1.155 ether);
    }
    function test_drip_multi_inblock() public {
        pot.drip();
        uint rho = pot.rho();
        asserteq(rho, now);
        hevm.warp(now + 1 days);
        rho = pot.rho();
        asserteq(rho, now  1 days);
        pot.drip();
        rho = pot.rho();
        asserteq(rho, now);
        pot.drip();
        rho = pot.rho();
        asserteq(rho, now);
    }
    function test_save_multi() public {
        pot.join(100 ether);
        pot.file(, uint(1000000564701133626865910626));  
        hevm.warp(now + 1 days);
        pot.drip();
        pot.exit(50 ether);
        asserteq(wad(vat.dai(self)), 52.5 ether);
        asserteq(pot.pie(),          50.0 ether);

        pot.file(, uint(1000001103127689513476993127));  
        hevm.warp(now + 1 days);
        pot.drip();
        pot.exit(50 ether);
        asserteq(wad(vat.dai(self)), 110.25 ether);
        asserteq(pot.pie(),            0.00 ether);
    }
    function test_fresh_chi() public {
        uint rho = pot.rho();
        asserteq(rho, now);
        hevm.warp(now + 1 days);
        asserteq(rho, now  1 days);
        pot.drip();
        pot.join(100 ether);
        asserteq(pot.pie(self), 100 ether);
        pot.exit(100 ether);
        
        asserteq(wad(vat.dai(self)), 100 ether);
    }
    function testfail_stale_chi() public {
        pot.file(, uint(1000000564701133626865910626));  
        pot.drip();
        hevm.warp(now + 1 days);
        pot.join(100 ether);
    }
    function test_file() public {
        hevm.warp(now + 1);
        pot.drip();
        pot.file(, uint(1));
    }
    function testfail_file() public {
        hevm.warp(now + 1);
        pot.file(, uint(1));
    }
}
