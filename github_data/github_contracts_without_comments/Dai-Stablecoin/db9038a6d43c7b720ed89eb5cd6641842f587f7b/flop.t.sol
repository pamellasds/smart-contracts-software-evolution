pragma solidity ^0.4.24;

import ;
import ;

import ;


contract hevm {
    function warp(uint256) public;
}

contract guy {
    flopper fuss;
    constructor(flopper fuss_) public {
        fuss = fuss_;
        dstoken(fuss.dai()).approve(fuss);
        dstoken(fuss.gem()).approve(fuss);
    }
    function dent(uint id, uint lot, uint bid) public {
        fuss.dent(id, lot, bid);
    }
    function deal(uint id) public {
        fuss.deal(id);
    }
    function try_dent(uint id, uint lot, uint bid)
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

contract vatlike is dstoken() {
    uint constant one = 10 ** 27;
    function move(bytes32 src, bytes32 dst, int wad) public {
        move(address(src), address(dst), uint(wad) / one);
    }
}

contract floptest is dstest {
    hevm hevm;

    flopper fuss;
    vatlike dai;
    dstoken gem;

    guy  ali;
    guy  bob;
    gal  gal;

    function kiss(uint) public pure { }  

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(1 hours);

        dai = new vatlike();
        gem = new dstoken();

        fuss = new flopper(dai, gem);

        ali = new guy(fuss);
        bob = new guy(fuss);
        gal = new gal();

        dai.approve(fuss);
        gem.approve(fuss);

        dai.mint(1000 ether);

        dai.push(ali, 200 ether);
        dai.push(bob, 200 ether);
    }
    function test_kick() public {
        asserteq(dai.balanceof(this), 600 ether);
        asserteq(gem.balanceof(this),   0 ether);
        fuss.kick({ lot: uint(1)   
                  , gal: gal
                  , bid: 0
                  });
        
        asserteq(dai.balanceof(this), 600 ether);
        asserteq(gem.balanceof(this),   0 ether);
    }
    function test_dent() public {
        uint id = fuss.kick({ lot: uint(1)   
                            , gal: gal
                            , bid: 10 ether
                            });

        ali.dent(id, 100 ether, 10 ether);
        
        asserteq(dai.balanceof(ali), 190 ether);
        
        asserteq(dai.balanceof(gal),  10 ether);

        bob.dent(id, 80 ether, 10 ether);
        
        asserteq(dai.balanceof(bob), 190 ether);
        
        asserteq(dai.balanceof(ali), 200 ether);
        
        asserteq(dai.balanceof(gal), 10 ether);

        hevm.warp(5 weeks);
        asserteq(gem.totalsupply(),  0 ether);
        gem.setowner(fuss);
        bob.deal(id);
        
        asserteq(gem.totalsupply(), 80 ether);
        
        asserteq(gem.balanceof(bob), 80 ether);
    }
}
