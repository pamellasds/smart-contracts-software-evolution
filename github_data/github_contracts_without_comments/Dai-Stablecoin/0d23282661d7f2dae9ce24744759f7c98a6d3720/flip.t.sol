pragma solidity ^0.4.24;

import ;
import ;

import ;
import {dai20} from ;

contract guy {
    flipper flip;
    constructor(flipper flip_) public {
        flip = flip_;
    }
    function tend(uint id, uint lot, uint bid) public {
        flip.tend(id, lot, bid);
    }
    function dent(uint id, uint lot, uint bid) public {
        flip.dent(id, lot, bid);
    }
    function deal(uint id) public {
        flip.deal(id);
    }
    function try_tend(uint id, uint lot, uint bid)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(flip).call(sig, id, lot, bid);
    }
    function try_dent(uint id, uint lot, uint bid)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(flip).call(sig, id, lot, bid);
    }
    function try_deal(uint id)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(flip).call(sig, id);
    }
    function try_tick(uint id)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(flip).call(sig, id);
    }
}

contract vat is vatlike {
    mapping (bytes32 => int)  public gems;
    mapping (bytes32 => uint) public dai;
    function slip(bytes32 ilk, bytes32 lad, int jam) public {
        gems[lad] += jam;
        ilk;
    }
    function flux(bytes32 ilk, bytes32 src, bytes32 dst, int jam) public {
        gems[src] = jam;
        gems[dst] += jam;
        ilk;
    }
    uint256 constant one = 10 ** 27;
    function move(bytes32 src, bytes32 dst, uint rad) public {
        dai[src] = rad;
        dai[dst] += rad;
    }
}

contract gal {}

contract warpflip is flipper {
    uint48 _era; function warp(uint48 era_) public { _era = era_; }
    function era() public view returns (uint48) { return _era; }
    constructor(address vat_, bytes32 ilk_) public
        flipper(vat_, ilk_) {}
}

contract fliptest is dstest {
    warpflip flip;
    dai20   pie;

    guy  ali;
    guy  bob;
    gal  gal;
    vat  vat;

    function setup() public {
        vat = new vat();
        pie = new dai20(vat);
        flip = new warpflip(vat, );

        flip.warp(1 hours);

        ali = new guy(flip);
        bob = new guy(flip);
        gal = new gal();

        pie.approve(flip);

        pie.push(ali, 200 ether);
        pie.push(bob, 200 ether);
    }
    function test_kick() public {
        flip.kick({ lot: 100 ether
                  , tab: 50 ether
                  , lad: address(0xacab)
                  , gal: gal
                  , bid: 0
                  });
    }
    function testfail_tend_empty() public {
        
        flip.tend(42, 0, 0);
    }
    function test_tend() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , lad: address(0xacab)
                            , gal: gal
                            , bid: 0
                            });

        ali.tend(id, 100 ether, 1 ether);
        
        asserteq(pie.balanceof(ali),   199 ether);
        
        asserteq(pie.balanceof(gal),     1 ether);

        bob.tend(id, 100 ether, 2 ether);
        
        asserteq(pie.balanceof(bob), 198 ether);
        
        asserteq(pie.balanceof(ali), 200 ether);
        
        asserteq(pie.balanceof(gal),   2 ether);

        flip.warp(5 hours);
        bob.deal(id);
        
        asserteq(vat.gems(bytes32(address(bob))), 100 ether);
    }
    function test_tend_later() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , lad: address(0xacab)
                            , gal: gal
                            , bid: 0
                            });
        flip.warp(5 hours);

        ali.tend(id, 100 ether, 1 ether);
        
        asserteq(pie.balanceof(ali), 199 ether);
        
        asserteq(pie.balanceof(gal),   1 ether);
    }
    function test_dent() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , lad: address(0xacab)
                            , gal: gal
                            , bid: 0
                            });
        ali.tend(id, 100 ether,  1 ether);
        bob.tend(id, 100 ether, 50 ether);

        ali.dent(id,  95 ether, 50 ether);
        
        asserteq(vat.gems(0xacab), 5 ether);
        asserteq(pie.balanceof(ali),  150 ether);
        asserteq(pie.balanceof(bob),  200 ether);
    }
    function test_beg() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , lad: address(0xacab)
                            , gal: gal
                            , bid: 0
                            });
        asserttrue( ali.try_tend(id, 100 ether, 1.00 ether));
        asserttrue(!bob.try_tend(id, 100 ether, 1.01 ether));
        
        asserttrue(!ali.try_tend(id, 100 ether, 1.01 ether));
        asserttrue( bob.try_tend(id, 100 ether, 1.07 ether));

        
        asserttrue( ali.try_tend(id, 100 ether, 49 ether));
        asserttrue( bob.try_tend(id, 100 ether, 50 ether));

        asserttrue(!ali.try_dent(id, 100 ether, 50 ether));
        asserttrue(!ali.try_dent(id,  99 ether, 50 ether));
        asserttrue( ali.try_dent(id,  95 ether, 50 ether));
    }
    function test_deal() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , lad: address(0xacab)
                            , gal: gal
                            , bid: 0
                            });

        
        ali.tend(id, 100 ether, 1 ether);
        asserttrue(!bob.try_deal(id));
        flip.warp(4.1 hours);
        asserttrue( bob.try_deal(id));

        uint ie = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , lad: address(0xacab)
                            , gal: gal
                            , bid: 0
                            });

        
        flip.warp(1 weeks);
        ali.tend(ie, 100 ether, 1 ether);
        asserttrue(!bob.try_deal(ie));
        flip.warp(1.1 weeks);
        asserttrue( bob.try_deal(ie));
    }
    function test_tick() public {
        
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , lad: address(0xacab)
                            , gal: gal
                            , bid: 0
                            });
        
        asserttrue(!ali.try_tick(id));
        
        flip.warp(2 weeks);
        
        asserttrue(!ali.try_tend(id, 100 ether, 1 ether));
        asserttrue(ali.try_tick(id));
        
        asserttrue( ali.try_tend(id, 100 ether, 1 ether));
    }
}
