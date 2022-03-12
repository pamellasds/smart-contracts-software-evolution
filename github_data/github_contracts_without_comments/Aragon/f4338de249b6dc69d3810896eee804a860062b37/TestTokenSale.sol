pragma solidity ^0.4.8;

import ;
import ;
import ;
import ;

contract testtokensale {
  uint public initialbalance = 0 ether;
  address factory;

  throwproxy throwproxy;

  function beforeall() {
    factory = address(new minimetokenfactory());
  }

  function beforeeach() {
    throwproxy = new throwproxy(address(this));
  }

  function testcreatesale() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, 0x1, 0x2, 10 finney, 13 finney, 2);

    assert.isfalse(sale.isactivated(), );
    assert.equal(sale.totalcollected(), 0, );
  }

  function testcantinitiateincorrectsale() {
    testtokensale(throwproxy).throwifstartpastblocktime();
    throwproxy.assertthrows();
  }

  function throwifstartpastblocktime() {
    new aragontokensalemock(0, 20, 0x1, 0x2, 10 finney, 13 finney, 2);
  }

  function testactivatesale() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 10 finney, 13 finney, 2);
    sale.deployant(factory, true);
    sale.activatesale();
    assert.istrue(sale.isactivated(), );
  }

  function testcannotactivatebeforedeployingant() {
    testtokensale(throwproxy).throwswhenactivatingbeforedeployingant();
    throwproxy.assertthrows();
  }

  function throwswhenactivatingbeforedeployingant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 10 finney, 13 finney, 2);
    sale.activatesale();
  }

  function testcannotredeployant() {
    testtokensale(throwproxy).throwswhenredeployingant();
    throwproxy.assertthrows();
  }

  function throwswhenredeployingant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 10 finney, 13 finney, 2);
    sale.deployant(factory, true);
    sale.deployant(factory, true);
  }

  function testonlymultisigcandeployant() {
    testtokensale(throwproxy).throwswhennonmultisigdeploysant();
    throwproxy.assertthrows();
  }

  function throwswhennonmultisigdeploysant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, 0x1, 0x3, 10 finney, 13 finney, 2);
    sale.deployant(factory, true);
  }

  function testsetpresaletokens() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), 0x2, 10 finney, 13 finney, 2);
    sale.deployant(factory, true);
    sale.allocatepresaletokens(0x1, 100);
    sale.allocatepresaletokens(0x2, 50);
    assert.equal(erc20(sale.token()).balanceof(0x1), 100, );
    assert.equal(erc20(sale.token()).totalsupply(), 150, );
  }

  function testcannotsetpresaletokensafteractivation() {
    testtokensale(throwproxy).throwifsetpresaletokensafteractivation();
    throwproxy.assertthrows();
  }

  function throwifsetpresaletokensafteractivation() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 10 finney, 13 finney, 2);
    sale.deployant(factory, true);
    sale.activatesale(); 
    sale.allocatepresaletokens(0x1, 100);
  }

  function testcannotsetpresaletokensaftersalestarts() {
    testtokensale(throwproxy).throwifsetpresaletokensaftersalestarts();
    throwproxy.assertthrows();
  }

  function throwifsetpresaletokensaftersalestarts() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 10 finney, 13 finney, 2);
    sale.deployant(factory, true);
    sale.setmockedblocknumber(13);
    sale.allocatepresaletokens(0x1, 100);
  }

  function testhascorrectpriceforstages() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 10 finney, 20 finney, 2);
    assert.equal(sale.getprice(10), 10 finney, );
    assert.equal(sale.getprice(13), 10 finney, );
    assert.equal(sale.getprice(14), 10 finney, );
    assert.equal(sale.getprice(15), 20 finney, );
    assert.equal(sale.getprice(18), 20 finney, );
    assert.equal(sale.getprice(19), 20 finney, );

    assert.equal(sale.getprice(9), 2**250, );
    assert.equal(sale.getprice(20), 2**250, );
  }

  function testhascorrectpriceformultistage() {
    aragontokensalemock sale = new aragontokensalemock(10, 40, address(this), address(this), 10 finney, 30 finney, 3);
    assert.equal(sale.getprice(10), 10 finney, );
    assert.equal(sale.getprice(19), 10 finney, );
    assert.equal(sale.getprice(20), 20 finney, );
    assert.equal(sale.getprice(25), 20 finney, );
    assert.equal(sale.getprice(30), 30 finney, );
    assert.equal(sale.getprice(39), 30 finney, );

    assert.equal(sale.getprice(9), 2**250, );
    assert.equal(sale.getprice(41), 2**250, );
  }

}
