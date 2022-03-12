pragma solidity ^0.4.24;

import ;
import ;

import {vat} from ;
import {pit} from ;
import {cat} from ;
import {vow} from ;
import {drip} from ;
import {gemjoin, ethjoin, daijoin} from ;
import {gemmove, daimove} from ;

import {flipper} from ;
import {flopper} from ;
import {flapper} from ;


contract hevm {
    function warp(uint256) public;
}

contract testvat is vat {
    uint256 constant one = 10 ** 27;
    function mint(address guy, uint wad) public {
        dai[bytes32(guy)] += wad * one;
        debt              += wad * one;
    }
    function balanceof(address guy) public returns (uint) {
        return dai[bytes32(guy)] / one;
    }
}

contract frobtest is dstest {
    testvat vat;
    pit     pit;
    dstoken gold;
    drip    drip;

    gemjoin gema;

    function try_frob(bytes32 ilk, int ink, int art) public returns(bool) {
        bytes4 sig = bytes4(keccak256());
        return address(pit).call(sig, ilk, ink, art);
    }

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }

    function setup() public {
        vat = new testvat();
        pit = new pit(vat);

        gold = new dstoken();
        gold.mint(1000 ether);

        vat.init();
        gema = new gemjoin(vat, , gold);

        pit.file(, , ray(1 ether));
        pit.file(, , 1000 ether);
        pit.file(, uint(1000 ether));
        drip = new drip(vat);
        drip.init();
        vat.rely(drip);

        gold.approve(gema);
        gold.approve(vat);

        vat.rely(pit);
        vat.rely(gema);

        gema.join(bytes32(address(this)), 1000 ether);
    }

    function gem(bytes32 ilk, address urn) internal view returns (uint) {
        return vat.gem(ilk, bytes32(urn)) / 10 ** 27;
    }
    function ink(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(urn)); art_;
        return ink_;
    }
    function art(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(urn)); ink_;
        return art_;
    }


    function test_join() public {
        gold.mint(500 ether);
        asserteq(gold.balanceof(this),       500 ether);
        asserteq(gold.balanceof(gema),   1000 ether);
        gema.join(bytes32(address(this)), 500 ether);
        asserteq(gold.balanceof(this),         0 ether);
        asserteq(gold.balanceof(gema),   1500 ether);
        gema.exit(this, 250 ether);
        asserteq(gold.balanceof(this),       250 ether);
        asserteq(gold.balanceof(gema),   1250 ether);
    }
    function test_lock() public {
        asserteq(ink(, this),    0 ether);
        asserteq(gem(, this), 1000 ether);
        pit.frob(, 6 ether, 0);
        asserteq(ink(, this),   6 ether);
        asserteq(gem(, this), 994 ether);
        pit.frob(, 6 ether, 0);
        asserteq(ink(, this),    0 ether);
        asserteq(gem(, this), 1000 ether);
    }
    function test_calm() public {
        
        
        pit.file(, , 10 ether);
        asserttrue( try_frob(, 10 ether, 9 ether));
        
        asserttrue(!try_frob(,  0 ether, 2 ether));
    }
    function test_cool() public {
        
        
        pit.file(, , 10 ether);
        asserttrue(try_frob(, 10 ether,  8 ether));
        pit.file(, , 5 ether);
        
        asserttrue(try_frob(,  0 ether, 1 ether));
    }
    function test_safe() public {
        
        
        pit.frob(, 10 ether, 5 ether);                
        asserttrue(!try_frob(, 0 ether, 6 ether));  
    }
    function test_nice() public {
        
        

        pit.frob(, 10 ether, 10 ether);
        pit.file(, , ray(0.5 ether));  

        
        asserttrue(!try_frob(,  0 ether,  1 ether));
        
        asserttrue( try_frob(,  0 ether, 1 ether));
        
        asserttrue(!try_frob(, 1 ether,  0 ether));
        
        asserttrue( try_frob(,  1 ether,  0 ether));

        
        
        asserttrue(!this.try_frob(, 2 ether, 4 ether));
        
        asserttrue(!this.try_frob(,  5 ether,  1 ether));

        
        asserttrue( this.try_frob(, 1 ether, 4 ether));
        pit.file(, , ray(0.4 ether));  
        
        asserttrue( this.try_frob(,  5 ether, 1 ether));
    }
}

contract jointest is dstest {
    testvat vat;
    ethjoin etha;
    daijoin daia;
    dstoken dai;
    bytes32 me;

    function setup() public {
        vat = new testvat();
        vat.init();

        etha = new ethjoin(vat, );
        vat.rely(etha);

        dai  = new dstoken();
        daia = new daijoin(vat, dai);
        vat.rely(daia);
        dai.setowner(daia);

        me = bytes32(address(this));
    }
    function () external payable {}
    function test_eth_join() public {
        etha.join.value(10 ether)(bytes32(address(this)));
        asserteq(vat.gem(, me), rad(10 ether));
    }
    function test_eth_exit() public {
        etha.join.value(50 ether)(bytes32(address(this)));
        etha.exit(this, 10 ether);
        asserteq(vat.gem(, me), rad(40 ether));
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }
    function test_dai_exit() public {
        vat.mint(address(me), 100 ether);
        daia.exit(this, 60 ether);
        asserteq(dai.balanceof(address(me)), 60 ether);
        asserteq(vat.dai(me),            rad(40 ether));
    }
    function test_dai_exit_join() public {
        vat.mint(address(me), 100 ether);
        daia.exit(this, 60 ether);
        dai.approve(daia, uint(1));
        daia.join(bytes32(address(this)), 30 ether);
        asserteq(dai.balanceof(address(me)), 30 ether);
        asserteq(vat.dai(me),            rad(70 ether));
    }
}

contract bitetest is dstest {
    hevm hevm;

    testvat vat;
    pit     pit;
    vow     vow;
    cat     cat;
    dstoken gold;
    drip    drip;

    gemjoin gema;
    gemmove gemm;
    daimove daim;

    flipper flip;
    flopper flop;
    flapper flap;

    dstoken gov;

    function try_frob(bytes32 ilk, int ink, int art) public returns(bool) {
        bytes4 sig = bytes4(keccak256());
        return address(vat).call(sig, ilk, ink, art);
    }

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }

    function gem(bytes32 ilk, address urn) internal view returns (uint) {
        return vat.gem(ilk, bytes32(urn)) / 10 ** 27;
    }
    function ink(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(urn)); art_;
        return ink_;
    }
    function art(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(urn)); ink_;
        return art_;
    }

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(0);

        gov = new dstoken();
        gov.mint(100 ether);

        vat = new testvat();
        pit = new pit(vat);
        vat.rely(pit);

        daim = new daimove(vat);
        vat.rely(daim);

        flap = new flapper(daim, gov);
        flop = new flopper(daim, gov);
        gov.setowner(flop);

        vow = new vow();
        vow.file(,  address(vat));
        vow.file(, address(flap));
        vow.file(, address(flop));
        flop.rely(vow);

        drip = new drip(vat);
        drip.init();
        drip.file(, bytes32(address(vow)));
        vat.rely(drip);

        cat = new cat(vat);
        cat.file(, pit);
        cat.file(, vow);
        vat.rely(cat);
        vow.rely(cat);

        gold = new dstoken();
        gold.mint(1000 ether);

        vat.init();
        gema = new gemjoin(vat, , gold);
        vat.rely(gema);
        gold.approve(gema);
        gema.join(bytes32(address(this)), 1000 ether);

        gemm = new gemmove(vat, );
        vat.rely(gemm);

        pit.file(, , ray(1 ether));
        pit.file(, , 1000 ether);
        pit.file(, uint(1000 ether));
        flip = new flipper(daim, gemm);
        cat.file(, , flip);
        cat.file(, , ray(1 ether));

        vat.rely(flip);
        vat.rely(flap);
        vat.rely(flop);

        daim.hope(flip);
        daim.hope(flop);
        gold.approve(vat);
        gov.approve(flap);
    }
    function test_happy_bite() public {
        
        
        pit.file(, , ray(2.5 ether));
        pit.frob(,  40 ether, 100 ether);

        
        pit.file(, , ray(2 ether));  

        asserteq(ink(, this),  40 ether);
        asserteq(art(, this), 100 ether);
        asserteq(vow.woe(), 0 ether);
        asserteq(gem(, this), 960 ether);
        uint id = cat.bite(, bytes32(address(this)));
        asserteq(ink(, this), 0);
        asserteq(art(, this), 0);
        asserteq(vow.sin(uint48(now)),      100 ether);
        asserteq(gem(, this), 960 ether);

        cat.file(, , uint(100 ether));
        uint auction = cat.flip(id, 100 ether);  

        asserteq(vat.balanceof(vow),   0 ether);
        flip.tend(auction, 40 ether,   1 ether);
        asserteq(vat.balanceof(vow),   1 ether);
        flip.tend(auction, 40 ether, 100 ether);
        asserteq(vat.balanceof(vow), 100 ether);

        asserteq(vat.balanceof(this),       0 ether);
        asserteq(gem(, this), 960 ether);
        vat.mint(this, 100 ether);  
        flip.dent(auction, 38 ether,  100 ether);
        asserteq(vat.balanceof(this), 100 ether);
        asserteq(vat.balanceof(vow),  100 ether);
        asserteq(gem(, this), 962 ether);
        asserteq(gem(, this), 962 ether);

        asserteq(vow.sin(uint48(now)),       100 ether);
        asserteq(vat.balanceof(vow), 100 ether);
    }

    function test_floppy_bite() public {
        pit.file(, , ray(2.5 ether));
        pit.frob(,  40 ether, 100 ether);
        pit.file(, , ray(2 ether));  

        asserteq(vow.sin(uint48(now)),   0 ether);
        cat.bite(, bytes32(address(this)));
        asserteq(vow.sin(uint48(now)), 100 ether);

        asserteq(vow.sin(), 100 ether);
        vow.flog(uint48(now));
        asserteq(vow.sin(),   0 ether);
        asserteq(vow.woe(), 100 ether);
        asserteq(vow.joy(),   0 ether);
        asserteq(vow.ash(),   0 ether);

        vow.file(, uint(10 ether));
        uint f1 = vow.flop();
        asserteq(vow.woe(),  90 ether);
        asserteq(vow.joy(),   0 ether);
        asserteq(vow.ash(),  10 ether);
        flop.dent(f1, 1000 ether, 10 ether);
        asserteq(vow.woe(),  90 ether);
        asserteq(vow.joy(),  10 ether);
        asserteq(vow.ash(),  10 ether);

        asserteq(gov.balanceof(this),  100 ether);
        hevm.warp(4 hours);
        flop.deal(f1);
        asserteq(gov.balanceof(this), 1100 ether);
    }

    function test_flappy_bite() public {
        
        vat.mint(vow, 100 ether);
        asserteq(vat.balanceof(vow),  100 ether);
        asserteq(gov.balanceof(this), 100 ether);

        vow.file(, uint(100 ether));
        asserteq(vow.awe(), 0 ether);
        uint id = vow.flap();

        asserteq(vat.balanceof(this),   0 ether);
        asserteq(gov.balanceof(this), 100 ether);
        flap.tend(id, 100 ether, 10 ether);
        hevm.warp(4 hours);
        flap.deal(id);
        asserteq(vat.balanceof(this),   100 ether);
        asserteq(gov.balanceof(this),    90 ether);
    }
}

contract foldtest is dstest {
    vat vat;

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }
    function tab(bytes32 ilk, bytes32 urn) internal view returns (uint) {
        (uint ink, uint art)  = vat.urns(ilk, urn); ink;
        (uint take, uint rate, uint ink, uint art) = vat.ilks(ilk); art; ink; take;
        return art * rate;
    }
    function jam(bytes32 ilk, bytes32 urn) internal view returns (uint) {
        (uint ink, uint art)  = vat.urns(ilk, urn); art;
        (uint take, uint rate, uint ink, uint art) = vat.ilks(ilk); art; ink; rate;
        return ink * take;
    }

    function setup() public {
        vat = new vat();
        vat.init();
    }
    function test_fold() public {
        vat.tune(, , , , 0, 1 ether);

        asserteq(tab(, ), rad(1.00 ether));
        vat.fold(, ,  int(ray(0.05 ether)));
        asserteq(tab(, ), rad(1.05 ether));
        asserteq(vat.dai(),     rad(0.05 ether));
    }
    function test_toll_down() public {
        vat.slip(, , int(rad(1 ether)));
        vat.slip(, , int(rad(2 ether)));
        vat.tune(, , , , 1 ether, 0);
        vat.tune(, , , , 2 ether, 0);

        asserteq(jam(, ),     rad(1.00 ether));
        asserteq(jam(, ),     rad(2.00 ether));
        vat.toll(, ,     int(ray(0.05 ether)));
        asserteq(jam(, ),     rad(0.95 ether));
        asserteq(jam(, ),     rad(1.90 ether));
        asserteq(vat.gem(, ), rad(0.15 ether));
    }
    function test_toll_up() public {
        vat.slip(, , int(rad(1 ether)));
        vat.slip(, , int(rad(1 ether)));
        vat.slip(, , int(rad(2 ether)));
        vat.tune(, , , , 1 ether, 0);
        vat.tune(, , , , 2 ether, 0);

        asserteq(jam(, ),     rad(1.00 ether));
        asserteq(jam(, ),     rad(2.00 ether));
        vat.toll(, ,      int(ray(0.05 ether)));
        asserteq(jam(, ),     rad(1.05 ether));
        asserteq(jam(, ),     rad(2.10 ether));
        asserteq(vat.gem(, ), rad(0.85 ether));
    }
}
