pragma solidity >=0.5.0;

import ;
import {dstoken} from ;

import {flipper} from ;

contract hevm {
    function warp(uint256) public;
}

contract guy {
    flipper flip;
    constructor(flipper flip_) public {
        flip = flip_;
        dstoken(address(flip.dai())).approve(address(flip));
        dstoken(address(flip.gem())).approve(address(flip));
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
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flip).call(abi.encodewithsignature(sig, id, lot, bid));
    }
    function try_dent(uint id, uint lot, uint bid)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flip).call(abi.encodewithsignature(sig, id, lot, bid));
    }
    function try_deal(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flip).call(abi.encodewithsignature(sig, id));
    }
    function try_tick(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flip).call(abi.encodewithsignature(sig, id));
    }
}

contract dai is dstoken() {
    function move(bytes32 src, bytes32 dst, uint wad) public {
        move(address(bytes20(src)), address(bytes20(dst)), wad);
    }
}
contract gem is dstoken() {
    function move(bytes32 src, bytes32 dst, uint wad) public {
        move(address(bytes20(src)), address(bytes20(dst)), wad);
    }
    function push(bytes32 guy, uint wad) public {
        push(address(bytes20(guy)), wad);
    }
}

contract gal {}


contract fliptest is dstest {
    hevm hevm;

    flipper flip;

    dai  dai;
    gem  gem;

    address ali;
    address bob;
    address gal;
    bytes32 urn = bytes32(bytes20(address(0xacab)));

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(1 hours);

        dai = new dai();
        gem = new gem();

        flip = new flipper(address(dai), address(gem));

        ali = address(new guy(flip));
        bob = address(new guy(flip));
        gal = address(new gal());

        dai.approve(address(flip));
        gem.approve(address(flip));

        gem.mint(address(this), 1000 ether);

        dai.mint(ali, 200 ether);
        dai.mint(bob, 200 ether);
    }
    function test_kick() public {
        flip.kick({ lot: 100 ether
                  , tab: 50 ether
                  , urn: urn
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
                            , urn: urn
                            , gal: gal
                            , bid: 0
                            });

        guy(ali).tend(id, 100 ether, 1 ether);
        
        asserteq(dai.balanceof(ali),   199 ether);
        
        asserteq(dai.balanceof(gal),     1 ether);

        guy(bob).tend(id, 100 ether, 2 ether);
        
        asserteq(dai.balanceof(bob), 198 ether);
        
        asserteq(dai.balanceof(ali), 200 ether);
        
        asserteq(dai.balanceof(gal),   2 ether);

        hevm.warp(5 hours);
        guy(bob).deal(id);
        
        asserteq(gem.balanceof(bob), 100 ether);
    }
    function test_tend_later() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: urn
                            , gal: gal
                            , bid: 0
                            });
        hevm.warp(5 hours);

        guy(ali).tend(id, 100 ether, 1 ether);
        
        asserteq(dai.balanceof(ali), 199 ether);
        
        asserteq(dai.balanceof(gal),   1 ether);
    }
    function test_dent() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: urn
                            , gal: gal
                            , bid: 0
                            });
        guy(ali).tend(id, 100 ether,  1 ether);
        guy(bob).tend(id, 100 ether, 50 ether);

        guy(ali).dent(id,  95 ether, 50 ether);
        
        asserteq(gem.balanceof(address(0xacab)), 5 ether);
        asserteq(dai.balanceof(ali),  150 ether);
        asserteq(dai.balanceof(bob),  200 ether);
    }
    function test_beg() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: urn
                            , gal: gal
                            , bid: 0
                            });
        asserttrue( guy(ali).try_tend(id, 100 ether, 1.00 ether));
        asserttrue(!guy(bob).try_tend(id, 100 ether, 1.01 ether));
        
        asserttrue(!guy(ali).try_tend(id, 100 ether, 1.01 ether));
        asserttrue( guy(bob).try_tend(id, 100 ether, 1.07 ether));

        
        asserttrue( guy(ali).try_tend(id, 100 ether, 49 ether));
        asserttrue( guy(bob).try_tend(id, 100 ether, 50 ether));

        asserttrue(!guy(ali).try_dent(id, 100 ether, 50 ether));
        asserttrue(!guy(ali).try_dent(id,  99 ether, 50 ether));
        asserttrue( guy(ali).try_dent(id,  95 ether, 50 ether));
    }
    function test_deal() public {
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: urn
                            , gal: gal
                            , bid: 0
                            });

        
        guy(ali).tend(id, 100 ether, 1 ether);
        asserttrue(!guy(bob).try_deal(id));
        hevm.warp(4.1 hours);
        asserttrue( guy(bob).try_deal(id));

        uint ie = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: urn
                            , gal: gal
                            , bid: 0
                            });

        
        hevm.warp(2 days);
        guy(ali).tend(ie, 100 ether, 1 ether);
        asserttrue(!guy(bob).try_deal(ie));
        hevm.warp(3 days);
        asserttrue( guy(bob).try_deal(ie));
    }
    function test_tick() public {
        
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: urn
                            , gal: gal
                            , bid: 0
                            });
        
        asserttrue(!guy(ali).try_tick(id));
        
        hevm.warp(2 weeks);
        
        asserttrue(!guy(ali).try_tend(id, 100 ether, 1 ether));
        asserttrue( guy(ali).try_tick(id));
        
        asserttrue( guy(ali).try_tend(id, 100 ether, 1 ether));
    }
    function test_no_deal_after_end() public {
        
        
        uint id = flip.kick({ lot: 100 ether
                            , tab: 50 ether
                            , urn: urn
                            , gal: gal
                            , bid: 0
                            });
        asserttrue(!guy(ali).try_deal(id));
        hevm.warp(2 weeks);
        asserttrue(!guy(ali).try_deal(id));
        asserttrue( guy(ali).try_tick(id));
        asserttrue(!guy(ali).try_deal(id));
    }
}
