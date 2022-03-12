pragma solidity ^0.4.8;

import ;
import ;
import ;
import ;
import ;
import ;

contract testtokensalecap {
  uint public initialbalance = 250 finney;

  address factory;

  throwproxy throwproxy;

  function beforeall() {
    factory = address(new minimetokenfactory());
  }

  function beforeeach() {
    throwproxy = new throwproxy(address(this));
  }

  function testcantfinalizenotendedsale() {
    testtokensalecap(throwproxy).throwswhenfinalizingnotendedsale();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingnotendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(19);
    ms.finalizesale(sale);
  }

  function testcantfinalizeifnotmultisig() {
    testtokensalecap(throwproxy).throwswhenfinalizingifnotmultisig();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingifnotmultisig() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(30);
    sale.finalizesale(1, 1);
  }

  function testcantfinalizewithincorrectcap() {
    testtokensalecap(throwproxy).throwswhenfinalizingwithincorrectcap();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingwithincorrectcap() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(21);
    ms.finalizesale(sale, 101 finney); 
  }

  function testcanfinalizeoncap() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(100 finney)(address(this));

    sale.revealcap(100 finney, sale.mock_capsecret());

    assert.istrue(sale.salefinalized(), );
  }

  function testfinalizingbeforecapchangeshardcap() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(99 finney)(address(this));

    sale.revealcap(100 finney, sale.mock_capsecret());

    assert.equal(sale.hardcap(), 100 finney, );
  }

  function testhardcap() {
    testtokensalecap(throwproxy).throwswhenhittinghardcap();
    throwproxy.assertthrows();
  }

  function throwswhenhittinghardcap() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.setmockedtotalcollected(1499999 ether + 950 finney); 
    sale.proxypayment.value(60 finney)(address(this));
  }

  function testcanfinalizeendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(14 finney)(address(this));

    assert.equal(erc20(sale.token()).balanceof(address(this)), 70 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 70 finney, );

    sale.setmockedblocknumber(21);
    ms.finalizesale(sale);

    assert.equal(erc20(sale.token()).balanceof(address(ms)), 30 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 100 finney, );
  }
}
