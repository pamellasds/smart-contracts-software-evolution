














pragma solidity 0.5.12;

import ;
import ;
import ;

import {vat}  from ;
import {cat}  from ;
import {vow}  from ;
import {pot}  from ;
import {flipper} from ;
import {flapper} from ;
import {flopper} from ;
import {gemjoin} from ;
import {end}  from ;
import {spotter} from ;

contract hevm {
    function warp(uint256) public;
}

contract usr {
    vat public vat;
    end public end;

    constructor(vat vat_, end end_) public {
        vat  = vat_;
        end  = end_;
    }
    function frob(bytes32 ilk, address u, address v, address w, int dink, int dart) public {
        vat.frob(ilk, u, v, w, dink, dart);
    }
    function flux(bytes32 ilk, address src, address dst, uint256 wad) public {
        vat.flux(ilk, src, dst, wad);
    }
    function move(address src, address dst, uint256 rad) public {
        vat.move(src, dst, rad);
    }
    function hope(address usr) public {
        vat.hope(usr);
    }
    function exit(gemjoin gema, address usr, uint wad) public {
        gema.exit(usr, wad);
    }
    function free(bytes32 ilk) public {
        end.free(ilk);
    }
    function pack(uint256 rad) public {
        end.pack(rad);
    }
    function cash(bytes32 ilk, uint wad) public {
        end.cash(ilk, wad);
    }
}

contract endtest is dstest {
    hevm hevm;

    vat   vat;
    end   end;
    vow   vow;
    pot   pot;
    cat   cat;

    spotter spot;

    struct ilk {
        dsvalue pip;
        dstoken gem;
        gemjoin gema;
        flipper flip;
    }

    mapping (bytes32 => ilk) ilks;

    flapper flap;
    flopper flop;

    uint constant wad = 10 ** 18;
    uint constant ray = 10 ** 27;

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * ray;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / ray;
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        (x >= y) ? z = y : z = x;
    }
    function dai(address urn) internal view returns (uint) {
        return vat.dai(urn) / ray;
    }
    function gem(bytes32 ilk, address urn) internal view returns (uint) {
        return vat.gem(ilk, urn);
    }
    function ink(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, urn); art_;
        return ink_;
    }
    function art(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, urn); ink_;
        return art_;
    }
    function art(bytes32 ilk) internal view returns (uint) {
        (uint art_, uint rate_, uint spot_, uint line_, uint dust_) = vat.ilks(ilk);
        rate_; spot_; line_; dust_;
        return art_;
    }
    function balanceof(bytes32 ilk, address usr) internal view returns (uint) {
        return ilks[ilk].gem.balanceof(usr);
    }

    function try_pot_file(bytes32 what, uint data) public returns(bool ok) {
        string memory sig = ;
        (ok,) = address(pot).call(abi.encodewithsignature(sig, what, data));
    }

    function init_collateral(bytes32 name) internal returns (ilk memory) {
        dstoken coin = new dstoken(name);
        coin.mint(20 ether);

        dsvalue pip = new dsvalue();
        spot.file(name, , address(pip));
        spot.file(name, , ray(1.5 ether));
        
        pip.poke(bytes32(5 * wad));

        vat.init(name);
        gemjoin gema = new gemjoin(address(vat), name, address(coin));

        
        vat.file(name, ,    ray(3 ether));
        vat.file(name, , rad(1000 ether));

        coin.approve(address(gema));
        coin.approve(address(vat));

        vat.rely(address(gema));

        flipper flip = new flipper(address(vat), name);
        vat.hope(address(flip));
        flip.rely(address(end));
        flip.rely(address(cat));
        cat.file(name, , address(flip));
        cat.file(name, , ray(1 ether));
        cat.file(name, , rad(15 ether));

        ilks[name].pip = pip;
        ilks[name].gem = coin;
        ilks[name].gema = gema;
        ilks[name].flip = flip;

        return ilks[name];
    }

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(604411200);

        vat = new vat();
        dstoken gov = new dstoken();

        flap = new flapper(address(vat), address(gov));
        flop = new flopper(address(vat), address(gov));
        gov.setowner(address(flop));

        vow = new vow(address(vat), address(flap), address(flop));

        pot = new pot(address(vat));
        vat.rely(address(pot));
        pot.file(, address(vow));

        cat = new cat(address(vat));
        cat.file(, address(vow));
        vat.rely(address(cat));
        vow.rely(address(cat));

        spot = new spotter(address(vat));
        vat.file(,         rad(1000 ether));
        vat.rely(address(spot));

        end = new end();
        end.file(, address(vat));
        end.file(, address(cat));
        end.file(, address(vow));
        end.file(, address(pot));
        end.file(, address(spot));
        end.file(, 1 hours);
        vat.rely(address(end));
        vow.rely(address(end));
        spot.rely(address(end));
        pot.rely(address(end));
        cat.rely(address(end));
        flap.rely(address(vow));
        flop.rely(address(vow));
    }

    function test_cage_basic() public {
        asserteq(end.live(), 1);
        asserteq(vat.live(), 1);
        asserteq(cat.live(), 1);
        asserteq(vow.live(), 1);
        asserteq(pot.live(), 1);
        asserteq(vow.flopper().live(), 1);
        asserteq(vow.flapper().live(), 1);
        end.cage();
        asserteq(end.live(), 0);
        asserteq(vat.live(), 0);
        asserteq(cat.live(), 0);
        asserteq(vow.live(), 0);
        asserteq(pot.live(), 0);
        asserteq(vow.flopper().live(), 0);
        asserteq(vow.flapper().live(), 0);
    }

    function test_cage_pot_drip() public {
        asserteq(pot.live(), 1);
        pot.drip();
        end.cage();

        asserteq(pot.live(), 0);
        asserteq(pot.dsr(), 10 ** 27);
        asserttrue(!try_pot_file(, 10 ** 27 + 1));
    }

    
    
    function test_cage_collateralised() public {
        ilk memory gold = init_collateral();

        usr ali = new usr(vat, end);

        
        address urn1 = address(ali);
        gold.gema.join(urn1, 10 ether);
        ali.frob(, urn1, urn1, urn1, 10 ether, 15 ether);
        

        
        asserteq(vat.debt(), rad(15 ether));
        asserteq(vat.vice(), 0);

        
        gold.pip.poke(bytes32(5 * wad));
        end.cage();
        end.cage();
        end.skim(, urn1);

        
        asserteq(art(, urn1), 0);
        asserteq(ink(, urn1), 7 ether);
        asserteq(vat.sin(address(vow)), rad(15 ether));

        
        asserteq(vat.debt(), rad(15 ether));
        asserteq(vat.vice(), rad(15 ether));

        
        ali.free();
        asserteq(ink(, urn1), 0);
        asserteq(gem(, urn1), 7 ether);
        ali.exit(gold.gema, address(this), 7 ether);

        hevm.warp(now + 1 hours);
        end.thaw();
        end.flow();
        asserttrue(end.fix() != 0);

        
        ali.hope(address(end));
        ali.pack(15 ether);
        vow.heal(rad(15 ether));

        
        asserteq(vat.debt(), 0);
        asserteq(vat.vice(), 0);

        ali.cash(, 15 ether);

        
        asserteq(dai(urn1), 0);
        asserteq(gem(, urn1), 3 ether);
        ali.exit(gold.gema, address(this), 3 ether);

        asserteq(gem(, address(end)), 0);
        asserteq(balanceof(, address(gold.gema)), 0);
    }

    
    
    function test_cage_undercollateralised() public {
        ilk memory gold = init_collateral();

        usr ali = new usr(vat, end);
        usr bob = new usr(vat, end);

        
        address urn1 = address(ali);
        gold.gema.join(urn1, 10 ether);
        ali.frob(, urn1, urn1, urn1, 10 ether, 15 ether);
        

        
        address urn2 = address(bob);
        gold.gema.join(urn2, 1 ether);
        bob.frob(, urn2, urn2, urn2, 1 ether, 3 ether);
        

        
        asserteq(vat.debt(), rad(18 ether));
        asserteq(vat.vice(), 0);

        
        gold.pip.poke(bytes32(2 * wad));
        end.cage();
        end.cage();
        end.skim(, urn1);  
        end.skim(, urn2);  

        
        asserteq(art(, urn1), 0);
        asserteq(ink(, urn1), 2.5 ether);
        asserteq(art(, urn2), 0);
        asserteq(ink(, urn2), 0);
        asserteq(vat.sin(address(vow)), rad(18 ether));

        
        asserteq(vat.debt(), rad(18 ether));
        asserteq(vat.vice(), rad(18 ether));

        
        ali.free();
        asserteq(ink(, urn1), 0);
        asserteq(gem(, urn1), 2.5 ether);
        ali.exit(gold.gema, address(this), 2.5 ether);

        hevm.warp(now + 1 hours);
        end.thaw();
        end.flow();
        asserttrue(end.fix() != 0);

        
        ali.hope(address(end));
        ali.pack(15 ether);
        vow.heal(rad(15 ether));

        
        asserteq(vat.debt(), rad(3 ether));
        asserteq(vat.vice(), rad(3 ether));

        ali.cash(, 15 ether);

        
        asserteq(dai(urn1), 0);
        uint256 fix = end.fix();
        asserteq(gem(, urn1), rmul(fix, 15 ether));
        ali.exit(gold.gema, address(this), rmul(fix, 15 ether));

        
        bob.hope(address(end));
        bob.pack(3 ether);
        vow.heal(rad(3 ether));

        
        asserteq(vat.debt(), 0);
        asserteq(vat.vice(), 0);

        bob.cash(, 3 ether);

        
        asserteq(dai(urn2), 0);
        asserteq(gem(, urn2), rmul(fix, 3 ether));
        bob.exit(gold.gema, address(this), rmul(fix, 3 ether));

        
        asserteq(gem(, address(end)), 1);
        asserteq(balanceof(, address(gold.gema)), 1);
    }

    
    
    function test_cage_skip() public {
        ilk memory gold = init_collateral();

        usr ali = new usr(vat, end);

        
        address urn1 = address(ali);
        gold.gema.join(urn1, 10 ether);
        ali.frob(, urn1, urn1, urn1, 10 ether, 15 ether);
        

        vat.file(, , ray(1 ether));     

        uint auction = cat.bite(, urn1);  
        asserteq(vat.vice(), rad(15 ether));    
        
        ali.move(address(ali), address(this), rad(1 ether));
        vat.hope(address(gold.flip));
        gold.flip.tend(auction, 10 ether, rad(1 ether)); 
        asserteq(dai(urn1), 14 ether);

        
        gold.pip.poke(bytes32(5 * wad));
        end.cage();
        end.cage();

        end.skip(, auction);
        asserteq(dai(address(this)), 1 ether);       
        vat.move(address(this), urn1, rad(1 ether)); 

        end.skim(, urn1);

        
        asserteq(art(, urn1), 0);
        asserteq(ink(, urn1), 7 ether);
        asserteq(vat.sin(address(vow)), rad(30 ether));

        
        vow.heal(min(vat.dai(address(vow)), vat.sin(address(vow))));
        
        asserteq(vat.debt(), rad(15 ether));
        asserteq(vat.vice(), rad(15 ether));

        
        ali.free();
        asserteq(ink(, urn1), 0);
        asserteq(gem(, urn1), 7 ether);
        ali.exit(gold.gema, address(this), 7 ether);

        hevm.warp(now + 1 hours);
        end.thaw();
        end.flow();
        asserttrue(end.fix() != 0);

        
        ali.hope(address(end));
        ali.pack(15 ether);
        vow.heal(rad(15 ether));

        
        asserteq(vat.debt(), 0);
        asserteq(vat.vice(), 0);

        ali.cash(, 15 ether);

        
        asserteq(dai(urn1), 0);
        asserteq(gem(, urn1), 3 ether);
        ali.exit(gold.gema, address(this), 3 ether);

        asserteq(gem(, address(end)), 0);
        asserteq(balanceof(, address(gold.gema)), 0);
    }

    
    
    function test_cage_collateralised_deficit() public {
        ilk memory gold = init_collateral();

        usr ali = new usr(vat, end);

        
        address urn1 = address(ali);
        gold.gema.join(urn1, 10 ether);
        ali.frob(, urn1, urn1, urn1, 10 ether, 15 ether);
        
        
        vat.suck(address(vow), address(ali), rad(1 ether));

        
        asserteq(vat.debt(), rad(16 ether));
        asserteq(vat.vice(), rad(1 ether));

        
        gold.pip.poke(bytes32(5 * wad));
        end.cage();
        end.cage();
        end.skim(, urn1);

        
        asserteq(art(, urn1), 0);
        asserteq(ink(, urn1), 7 ether);
        asserteq(vat.sin(address(vow)), rad(16 ether));

        
        asserteq(vat.debt(), rad(16 ether));
        asserteq(vat.vice(), rad(16 ether));

        
        ali.free();
        asserteq(ink(, urn1), 0);
        asserteq(gem(, urn1), 7 ether);
        ali.exit(gold.gema, address(this), 7 ether);

        hevm.warp(now + 1 hours);
        end.thaw();
        end.flow();
        asserttrue(end.fix() != 0);

        
        ali.hope(address(end));
        ali.pack(16 ether);
        vow.heal(rad(16 ether));

        
        asserteq(vat.debt(), 0);
        asserteq(vat.vice(), 0);

        ali.cash(, 16 ether);

        
        asserteq(dai(urn1), 0);
        asserteq(gem(, urn1), 3 ether);
        ali.exit(gold.gema, address(this), 3 ether);

        asserteq(gem(, address(end)), 0);
        asserteq(balanceof(, address(gold.gema)), 0);
    }

    
    
    
    function test_cage_undercollateralised_surplus() public {
        ilk memory gold = init_collateral();

        usr ali = new usr(vat, end);
        usr bob = new usr(vat, end);

        
        address urn1 = address(ali);
        gold.gema.join(urn1, 10 ether);
        ali.frob(, urn1, urn1, urn1, 10 ether, 15 ether);
        
        
        ali.move(address(ali), address(vow), rad(1 ether));

        
        address urn2 = address(bob);
        gold.gema.join(urn2, 1 ether);
        bob.frob(, urn2, urn2, urn2, 1 ether, 3 ether);
        

        
        asserteq(vat.debt(), rad(18 ether));
        asserteq(vat.vice(), 0);

        
        gold.pip.poke(bytes32(2 * wad));
        end.cage();
        end.cage();
        end.skim(, urn1);  
        end.skim(, urn2);  

        
        asserteq(art(, urn1), 0);
        asserteq(ink(, urn1), 2.5 ether);
        asserteq(art(, urn2), 0);
        asserteq(ink(, urn2), 0);
        asserteq(vat.sin(address(vow)), rad(18 ether));

        
        asserteq(vat.debt(), rad(18 ether));
        asserteq(vat.vice(), rad(18 ether));

        
        ali.free();
        asserteq(ink(, urn1), 0);
        asserteq(gem(, urn1), 2.5 ether);
        ali.exit(gold.gema, address(this), 2.5 ether);

        hevm.warp(now + 1 hours);
        
        vow.heal(rad(1 ether));
        end.thaw();
        end.flow();
        asserttrue(end.fix() != 0);

        
        ali.hope(address(end));
        ali.pack(14 ether);
        vow.heal(rad(14 ether));

        
        asserteq(vat.debt(), rad(3 ether));
        asserteq(vat.vice(), rad(3 ether));

        ali.cash(, 14 ether);

        
        asserteq(dai(urn1), 0);
        uint256 fix = end.fix();
        asserteq(gem(, urn1), rmul(fix, 14 ether));
        ali.exit(gold.gema, address(this), rmul(fix, 14 ether));

        
        bob.hope(address(end));
        bob.pack(3 ether);
        vow.heal(rad(3 ether));

        
        asserteq(vat.debt(), 0);
        asserteq(vat.vice(), 0);

        bob.cash(, 3 ether);

        
        asserteq(dai(urn2), 0);
        asserteq(gem(, urn2), rmul(fix, 3 ether));
        bob.exit(gold.gema, address(this), rmul(fix, 3 ether));

        
        asserteq(gem(, address(end)), 0);
        asserteq(balanceof(, address(gold.gema)), 0);
    }

    
    
    
    function test_cage_net_undercollateralised_multiple_ilks() public {
        ilk memory gold = init_collateral();
        ilk memory coal = init_collateral();

        usr ali = new usr(vat, end);
        usr bob = new usr(vat, end);

        
        address urn1 = address(ali);
        gold.gema.join(urn1, 10 ether);
        ali.frob(, urn1, urn1, urn1, 10 ether, 15 ether);
        

        
        address urn2 = address(bob);
        coal.gema.join(urn2, 1 ether);
        vat.file(, , ray(5 ether));
        bob.frob(, urn2, urn2, urn2, 1 ether, 5 ether);
        

        gold.pip.poke(bytes32(2 * wad));
        
        coal.pip.poke(bytes32(2 * wad));
        
        end.cage();
        end.cage();
        end.cage();
        end.skim(, urn1);  
        end.skim(, urn2);  

        hevm.warp(now + 1 hours);
        end.thaw();
        end.flow();
        end.flow();

        ali.hope(address(end));
        bob.hope(address(end));

        asserteq(vat.debt(),             rad(20 ether));
        asserteq(vat.vice(),             rad(20 ether));
        asserteq(vat.sin(address(vow)),  rad(20 ether));

        asserteq(end.art(), 15 ether);
        asserteq(end.art(),  5 ether);

        asserteq(end.gap(),  0.0 ether);
        asserteq(end.gap(),  1.5 ether);

        
        
        
        
        
        asserteq(end.fix(), ray(0.375 ether));
        asserteq(end.fix(), ray(0.050 ether));

        asserteq(gem(, address(ali)), 0 ether);
        ali.pack(1 ether);
        ali.cash(, 1 ether);
        asserteq(gem(, address(ali)), 0.375 ether);

        bob.pack(1 ether);
        bob.cash(, 1 ether);
        asserteq(gem(, address(bob)), 0.05 ether);

        ali.exit(gold.gema, address(ali), 0.375 ether);
        bob.exit(coal.gema, address(bob), 0.05  ether);
        ali.pack(1 ether);
        ali.cash(, 1 ether);
        ali.cash(, 1 ether);
        asserteq(gem(, address(ali)), 0.375 ether);
        asserteq(gem(, address(ali)), 0.05 ether);

        ali.exit(gold.gema, address(ali), 0.375 ether);
        ali.exit(coal.gema, address(ali), 0.05  ether);

        ali.pack(1 ether);
        ali.cash(, 1 ether);
        asserteq(end.out(, address(ali)), 3 ether);
        asserteq(end.out(, address(ali)), 1 ether);
        ali.pack(1 ether);
        ali.cash(, 1 ether);
        asserteq(end.out(, address(ali)), 3 ether);
        asserteq(end.out(, address(ali)), 2 ether);
        asserteq(gem(, address(ali)), 0.375 ether);
        asserteq(gem(, address(ali)), 0.05 ether);
    }
}
