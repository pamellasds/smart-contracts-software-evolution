pragma solidity ^0.4.23;

import ;
import ;

import ;

contract guy {
    flapper fuss;
    constructor(flapper fuss_) public {
        fuss = fuss_;
        dstoken(fuss.pie()).approve(fuss);
        dstoken(fuss.gem()).approve(fuss);
    }
    function tend(uint id, uint lot, uint bid) public {
        fuss.tend(id, lot, bid);
    }
    function deal(uint id) public {
        fuss.deal(id);
    }
    function try_tend(uint id, uint lot, uint bid)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(fuss).call(sig, id, lot, bid);
    }
    function try_deal(uint id)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(fuss).call(sig, id);
    }
}

contract gal {}

contract warpflap is flapper {
    uint48 _era; function warp(uint48 era_) public { _era = era_; }
    function era() public view returns (uint48) { return _era; }
    constructor(address pie_, address gem_) public flapper(pie_, gem_) {}
}

contract flaptest is dstest {
    warpflap fuss;
    dstoken pie;
    dstoken gem;

    guy  ali;
    guy  bob;
    gal  gal;

    function setup() public {
        pie = new dstoken();
        gem = new dstoken();

        fuss = new warpflap(pie, gem);

        fuss.warp(1 hours);

        ali = new guy(fuss);
        bob = new guy(fuss);
        gal = new gal();

        pie.approve(fuss);
        gem.approve(fuss);

        pie.mint(1000 ether);
        gem.mint(1000 ether);

        gem.push(ali, 200 ether);
        gem.push(bob, 200 ether);
    }
    function test_kick() public {
        asserteq(pie.balanceof(this), 1000 ether);
        asserteq(pie.balanceof(fuss),    0 ether);
        fuss.kick({ lot: 100 ether
                  , gal: gal
                  , bid: 0
                  });
        asserteq(pie.balanceof(this),  900 ether);
        asserteq(pie.balanceof(fuss),  100 ether);
    }
    function test_tend() public {
        uint id = fuss.kick({ lot: 100 ether
                            , gal: gal
                            , bid: 0
                            });
        
        asserteq(pie.balanceof(this), 900 ether);

        ali.tend(id, 100 ether, 1 ether);
        
        asserteq(gem.balanceof(ali), 199 ether);
        
        asserteq(gem.balanceof(gal),   1 ether);

        bob.tend(id, 100 ether, 2 ether);
        
        asserteq(gem.balanceof(bob), 198 ether);
        
        asserteq(gem.balanceof(ali), 200 ether);
        
        asserteq(gem.balanceof(gal),   2 ether);

        fuss.warp(5 weeks);
        bob.deal(id);
        
        asserteq(pie.balanceof(fuss),  0 ether);
        asserteq(pie.balanceof(bob), 100 ether);
    }
    function test_beg() public {
        uint id = fuss.kick({ lot: 100 ether
                            , gal: gal
                            , bid: 0
                            });
        asserttrue( ali.try_tend(id, 100 ether, 1.00 ether));
        asserttrue(!bob.try_tend(id, 100 ether, 1.01 ether));
        
        asserttrue(!ali.try_tend(id, 100 ether, 1.01 ether));
        asserttrue( bob.try_tend(id, 100 ether, 1.07 ether));
    }
}
