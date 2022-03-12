pragma solidity ^0.4.24;

import ;
import ;

import ;

contract guy {
    flipper flip;
    constructor(flipper flip_) public {
        flip = flip_;
        dstoken(flip.dai()).approve(flip);
        dstoken(flip.gem()).approve(flip);
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

contract vat is dstoken {
    mapping (bytes32 => uint) public gems;
    mapping (bytes32 => uint) public dai;
    uint256 constant one = 10 ** 27;
    function flux(bytes32 ilk, bytes32 src, bytes32 dst, int jam) public {
        gems[src] = uint(jam) / one;
        gems[dst] += uint(jam) / one;
        ilk;
    }
    function move(bytes32 src, bytes32 dst, int rad) public {
        dai[src] = uint(rad);
        dai[dst] += uint(rad);
    }
}

contract dai is dstoken() {}
contract gem is dstoken() {
    function push(bytes32 guy, uint wad) public {
        push(address(guy), wad);
    }
}

contract gal {}

contract warpflip is flipper {
    uint48 _era; function warp(uint48 era_) public { _era = era_; }
    function era() public view returns (uint48) { return _era; }
    constructor(address dai_, address gem_) public
        flipper(dai_, gem_) {}
}

contract fliptest is dstest {
    warpflip flip;

    dai  dai;
    gem  gem;

    guy  ali;
    guy  bob;
    gal  gal;
    vat  vat;

    function setup() public {
        dai = new dai();
        gem = new gem();

        flip = new warpflip(dai, gem);

        flip.warp(1 hours);

        ali = new guy(flip);
        bob = new guy(flip);
        gal = new gal();

        dai.approve(flip);
        gem.approve(flip);

        gem.mint(this, 1000 ether);

        dai.mint(ali, 200 ether);
        dai.mint(bob, 200 ether);
    }
    function test_kick() public {
        flip.kick({ lot: 100 ether
                  , tab: 50 ether
                  , urn: bytes32(address(0xacab))
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
                            , urn: bytes32(address(0xacab))
                            , gal: gal
                            , bid: 0
                            });

        ali.tend(id, 100 ether, 1 ether);
        
        asserteq(dai.balanceof(ali),   199 ether);
        
        asserteq(dai.balanceof(gal),     1 ether);

        bob.tend(id, 100 ether, 2 ether);
        
        asserteq(dai.balanceof(bob), 198 ether);
        
        asserteq(dai.balanceof(ali), 200 ether);
        
        asserteq(dai.balanceof(gal),   2 ether);

        flip.warp(5 hours);
        bob.deal(id);
        
        asserteq(gem.balanceof(bob), 100 ether);
    }
    function test_tend_later() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: bytes32(address(0xacab))
                            , gal: gal
                            , bid: 0
                            });
        flip.warp(5 hours);

        ali.tend(id, 100 ether, 1 ether);
        
        asserteq(dai.balanceof(ali), 199 ether);
        
        asserteq(dai.balanceof(gal),   1 ether);
    }
    function test_dent() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: bytes32(address(0xacab))
                            , gal: gal
                            , bid: 0
                            });
        ali.tend(id, 100 ether,  1 ether);
        bob.tend(id, 100 ether, 50 ether);

        ali.dent(id,  95 ether, 50 ether);
        
        asserteq(gem.balanceof(0xacab), 5 ether);
        asserteq(dai.balanceof(ali),  150 ether);
        asserteq(dai.balanceof(bob),  200 ether);
    }
    function test_beg() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: bytes32(address(0xacab))
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
                            , urn: bytes32(address(0xacab))
                            , gal: gal
                            , bid: 0
                            });

        
        ali.tend(id, 100 ether, 1 ether);
        asserttrue(!bob.try_deal(id));
        flip.warp(4.1 hours);
        asserttrue( bob.try_deal(id));

        uint ie = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: bytes32(address(0xacab))
                            , gal: gal
                            , bid: 0
                            });

        
        flip.warp(2 days);
        ali.tend(ie, 100 ether, 1 ether);
        asserttrue(!bob.try_deal(ie));
        flip.warp(3 days);
        asserttrue( bob.try_deal(ie));
    }
    function test_tick() public {
        
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: bytes32(address(0xacab))
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
